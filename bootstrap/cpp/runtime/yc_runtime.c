#include "yc_runtime.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define YC_ALLOC_MAGIC ((uint64_t)0x5943504c52544d45ULL)

typedef struct YcAllocHeader {
    uint64_t magic;
    size_t size;
    uint32_t frame;
    uint32_t flags;
    struct YcAllocHeader *prev;
    struct YcAllocHeader *next;
    struct YcAllocHeader *frame_prev;
    struct YcAllocHeader *frame_next;
    void *children[4];
    uint32_t child_count;
} YcAllocHeader;

static YcAllocHeader *yc_head = NULL;
static uint32_t yc_current_frame = 0;
static YcAllocHeader **yc_frame_heads = NULL;
static size_t yc_frame_heads_cap = 0;
static YcAllocHeader **yc_registry = NULL;
static size_t yc_registry_cap = 0;
static size_t yc_registry_count = 0;
static size_t yc_registry_used = 0;

#define YC_REGISTRY_TOMBSTONE ((YcAllocHeader *)(uintptr_t)1)

static uintptr_t yc_ptr_hash(void *ptr) {
    uintptr_t x = (uintptr_t)ptr;
    x ^= x >> 33;
    x *= (uintptr_t)0xff51afd7ed558ccdULL;
    x ^= x >> 33;
    x *= (uintptr_t)0xc4ceb9fe1a85ec53ULL;
    x ^= x >> 33;
    return x;
}

static int yc_registry_resize(size_t next_cap) {
    YcAllocHeader **old_registry = yc_registry;
    size_t old_cap = yc_registry_cap;

    YcAllocHeader **next = (YcAllocHeader **)calloc(next_cap, sizeof(YcAllocHeader *));
    if (!next) {
        return 0;
    }

    yc_registry = next;
    yc_registry_cap = next_cap;
    yc_registry_count = 0;
    yc_registry_used = 0;

    for (size_t i = 0; i < old_cap; ++i) {
        YcAllocHeader *header = old_registry[i];
        if (!header || header == YC_REGISTRY_TOMBSTONE) {
            continue;
        }

        void *ptr = (void *)(header + 1);
        size_t mask = yc_registry_cap - 1;
        size_t slot = (size_t)yc_ptr_hash(ptr) & mask;
        while (yc_registry[slot]) {
            slot = (slot + 1) & mask;
        }
        yc_registry[slot] = header;
        yc_registry_count++;
        yc_registry_used++;
    }

    free(old_registry);
    return 1;
}

static int yc_registry_ensure(void) {
    if (yc_registry_cap == 0) {
        return yc_registry_resize(1024);
    }
    if ((yc_registry_used + 1) * 3 >= yc_registry_cap * 2) {
        return yc_registry_resize(yc_registry_cap * 2);
    }
    return 1;
}

static void yc_registry_insert(YcAllocHeader *header) {
    if (!yc_registry_ensure()) {
        return;
    }

    void *ptr = (void *)(header + 1);
    size_t mask = yc_registry_cap - 1;
    size_t slot = (size_t)yc_ptr_hash(ptr) & mask;
    size_t first_tombstone = (size_t)-1;

    while (yc_registry[slot]) {
        if (yc_registry[slot] == YC_REGISTRY_TOMBSTONE) {
            if (first_tombstone == (size_t)-1) {
                first_tombstone = slot;
            }
        } else if (yc_registry[slot] == header) {
            return;
        }
        slot = (slot + 1) & mask;
    }

    if (first_tombstone != (size_t)-1) {
        slot = first_tombstone;
    } else {
        yc_registry_used++;
    }
    yc_registry[slot] = header;
    yc_registry_count++;
}

static void yc_registry_remove(YcAllocHeader *header) {
    if (!yc_registry || !header) {
        return;
    }

    void *ptr = (void *)(header + 1);
    size_t mask = yc_registry_cap - 1;
    size_t slot = (size_t)yc_ptr_hash(ptr) & mask;

    while (yc_registry[slot]) {
        if (yc_registry[slot] == header) {
            yc_registry[slot] = YC_REGISTRY_TOMBSTONE;
            if (yc_registry_count > 0) {
                yc_registry_count--;
            }
            return;
        }
        slot = (slot + 1) & mask;
    }
}

static int yc_frame_heads_ensure(uint32_t frame) {
    size_t need = (size_t)frame + 1;
    if (need <= yc_frame_heads_cap) {
        return 1;
    }

    size_t next_cap = yc_frame_heads_cap == 0 ? 64 : yc_frame_heads_cap;
    while (next_cap < need) {
        next_cap *= 2;
    }

    YcAllocHeader **next = (YcAllocHeader **)realloc(yc_frame_heads, next_cap * sizeof(YcAllocHeader *));
    if (!next) {
        return 0;
    }
    for (size_t i = yc_frame_heads_cap; i < next_cap; ++i) {
        next[i] = NULL;
    }
    yc_frame_heads = next;
    yc_frame_heads_cap = next_cap;
    return 1;
}

static void yc_frame_link(YcAllocHeader *header, uint32_t frame) {
    if (!header || !yc_frame_heads_ensure(frame)) {
        return;
    }
    header->frame = frame;
    header->frame_prev = NULL;
    header->frame_next = yc_frame_heads[frame];
    if (yc_frame_heads[frame]) {
        yc_frame_heads[frame]->frame_prev = header;
    }
    yc_frame_heads[frame] = header;
}

static void yc_frame_unlink(YcAllocHeader *header) {
    if (!header || header->frame >= yc_frame_heads_cap) {
        return;
    }
    uint32_t frame = header->frame;
    if (header->frame_prev) {
        header->frame_prev->frame_next = header->frame_next;
    } else if (yc_frame_heads[frame] == header) {
        yc_frame_heads[frame] = header->frame_next;
    }
    if (header->frame_next) {
        header->frame_next->frame_prev = header->frame_prev;
    }
    header->frame_prev = NULL;
    header->frame_next = NULL;
}

static void yc_frame_move_all(uint32_t from, uint32_t to) {
    if (from >= yc_frame_heads_cap || from == to) {
        return;
    }

    YcAllocHeader *header = yc_frame_heads[from];
    while (header) {
        YcAllocHeader *next = header->frame_next;
        yc_frame_unlink(header);
        yc_frame_link(header, to);
        header = next;
    }
}

static YcAllocHeader *yc_header_from_ptr(void *ptr) {
    if (!ptr) {
        return NULL;
    }

    if (!yc_registry) {
        return NULL;
    }

    size_t mask = yc_registry_cap - 1;
    size_t slot = (size_t)yc_ptr_hash(ptr) & mask;
    while (yc_registry[slot]) {
        YcAllocHeader *header = yc_registry[slot];
        if (header != YC_REGISTRY_TOMBSTONE && (void *)(header + 1) == ptr && header->magic == YC_ALLOC_MAGIC) {
            return header;
        }
        slot = (slot + 1) & mask;
    }

    return NULL;
}

static void yc_link(YcAllocHeader *header) {
    header->prev = NULL;
    header->next = yc_head;
    header->frame_prev = NULL;
    header->frame_next = NULL;
    if (yc_head) {
        yc_head->prev = header;
    }
    yc_head = header;
}

static void yc_unlink(YcAllocHeader *header) {
    if (!header) {
        return;
    }
    if (header->prev) {
        header->prev->next = header->next;
    } else if (yc_head == header) {
        yc_head = header->next;
    }
    if (header->next) {
        header->next->prev = header->prev;
    }
    header->prev = NULL;
    header->next = NULL;
}

static void yc_release_header(YcAllocHeader *header) {
    if (!header || header->magic != YC_ALLOC_MAGIC) {
        return;
    }
    void *children[4];
    uint32_t child_count = header->child_count;
    if (child_count > 4) {
        child_count = 4;
    }
    for (uint32_t i = 0; i < child_count; ++i) {
        children[i] = header->children[i];
    }
    header->child_count = 0;
    yc_frame_unlink(header);
    yc_unlink(header);
    yc_registry_remove(header);
    header->magic = 0;
    free(header);

    for (uint32_t i = 0; i < child_count; ++i) {
        yc_release(children[i]);
    }
}

void yc_runtime_init(void) {
    yc_current_frame = 0;
}

void yc_runtime_shutdown(void) {
    while (yc_head) {
        YcAllocHeader *next = yc_head->next;
        yc_head->magic = 0;
        free(yc_head);
        yc_head = next;
    }
    free(yc_registry);
    free(yc_frame_heads);
    yc_registry = NULL;
    yc_registry_cap = 0;
    yc_registry_count = 0;
    yc_registry_used = 0;
    yc_frame_heads = NULL;
    yc_frame_heads_cap = 0;
    yc_current_frame = 0;
}

void yc_frame_push(void) {
    yc_current_frame++;
    yc_frame_heads_ensure(yc_current_frame);
}

void yc_frame_pop(void) {
    if (yc_current_frame == 0) {
        return;
    }
    uint32_t frame = yc_current_frame;
    while (frame < yc_frame_heads_cap && yc_frame_heads[frame]) {
        yc_release_header(yc_frame_heads[frame]);
    }
    if (yc_current_frame > 0) {
        yc_current_frame--;
    }
}

void *yc_alloc(size_t size) {
    YcAllocHeader *header = (YcAllocHeader *)malloc(sizeof(YcAllocHeader) + size);
    if (!header) {
        return NULL;
    }
    header->magic = YC_ALLOC_MAGIC;
    header->size = size;
    header->flags = 0;
    header->child_count = 0;
    for (uint32_t i = 0; i < 4; ++i) {
        header->children[i] = NULL;
    }
    yc_link(header);
    yc_frame_link(header, yc_current_frame);
    yc_registry_insert(header);
    return (void *)(header + 1);
}

void *yc_calloc(size_t count, size_t size) {
    size_t total = count * size;
    void *ptr = yc_alloc(total);
    if (ptr) {
        memset(ptr, 0, total);
    }
    return ptr;
}

void *yc_realloc(void *ptr, size_t size) {
    if (!ptr) {
        return yc_alloc(size);
    }
    YcAllocHeader *old_header = yc_header_from_ptr(ptr);
    if (!old_header) {
        return NULL;
    }
    size_t copy_size = old_header->size < size ? old_header->size : size;
    void *next = yc_alloc(size);
    if (!next) {
        return NULL;
    }
    memcpy(next, ptr, copy_size);
    yc_release(ptr);
    return next;
}

void yc_release(void *ptr) {
    YcAllocHeader *header = yc_header_from_ptr(ptr);
    if (!header) {
        return;
    }
    yc_release_header(header);
}

void yc_attach_child(void *parent, void *child) {
    if (!parent || !child || parent == child) {
        return;
    }

    YcAllocHeader *parent_header = yc_header_from_ptr(parent);
    YcAllocHeader *child_header = yc_header_from_ptr(child);
    if (!parent_header || !child_header) {
        return;
    }

    for (uint32_t i = 0; i < parent_header->child_count && i < 4; ++i) {
        if (parent_header->children[i] == child) {
            return;
        }
    }

    if (parent_header->child_count < 4) {
        parent_header->children[parent_header->child_count] = child;
        parent_header->child_count++;
    }
}

void yc_replace_child(void *parent, void *old_child, void *new_child) {
    if (!parent || !new_child || parent == new_child) {
        return;
    }

    YcAllocHeader *parent_header = yc_header_from_ptr(parent);
    YcAllocHeader *new_header = yc_header_from_ptr(new_child);
    if (!parent_header || !new_header) {
        return;
    }

    for (uint32_t i = 0; i < parent_header->child_count && i < 4; ++i) {
        if (parent_header->children[i] == new_child) {
            return;
        }
    }

    if (old_child) {
        for (uint32_t i = 0; i < parent_header->child_count && i < 4; ++i) {
            if (parent_header->children[i] == old_child) {
                parent_header->children[i] = new_child;
                return;
            }
        }
    }

    yc_attach_child(parent, new_child);
}

void *yc_move_to_parent(void *ptr) {
    YcAllocHeader *header = yc_header_from_ptr(ptr);
    if (!header) {
        return ptr;
    }
    if (header->frame != yc_current_frame || yc_current_frame == 0) {
        return ptr;
    }
    yc_frame_move_all(header->frame, header->frame - 1);
    return ptr;
}

void yc_move_frame_to_parent(void) {
    if (yc_current_frame == 0) {
        return;
    }
    yc_frame_move_all(yc_current_frame, yc_current_frame - 1);
}

void *yc_move_to_root(void *ptr) {
    YcAllocHeader *header = yc_header_from_ptr(ptr);
    if (!header || header->frame <= 1) {
        return ptr;
    }
    yc_frame_unlink(header);
    yc_frame_link(header, 1);
    return ptr;
}

char *yc_keep_string(const char *ptr) {
    if (!ptr) {
        return NULL;
    }
    size_t len = strlen(ptr);
    char *copy = (char *)yc_alloc(len + 1);
    if (!copy) {
        return NULL;
    }
    memcpy(copy, ptr, len + 1);
    return (char *)yc_move_to_root(copy);
}

size_t yc_runtime_live_allocations(void) {
    return yc_registry_count;
}
