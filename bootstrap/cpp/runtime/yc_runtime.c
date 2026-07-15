#include "yc_runtime.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <dirent.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#if defined(__APPLE__)
#include <mach-o/dyld.h>
#endif

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
    struct YcAllocHeader *owner;
    struct YcAllocHeader *first_child;
    struct YcAllocHeader *sibling_prev;
    struct YcAllocHeader *sibling_next;
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

static void yc_move_graph_to_frame(YcAllocHeader *header, uint32_t frame) {
    if (!header) {
        return;
    }
    if (header->frame != frame) {
        yc_frame_unlink(header);
        yc_frame_link(header, frame);
    }
    for (YcAllocHeader *child = header->first_child; child; child = child->sibling_next) {
        yc_move_graph_to_frame(child, frame);
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

static YcAllocHeader *yc_header_containing_ptr(void *ptr) {
    return yc_header_from_ptr(ptr);
}

static YcAllocHeader *yc_owner_root(YcAllocHeader *header) {
    while (header && header->owner) {
        header = header->owner;
    }
    return header;
}

static int yc_is_owner_ancestor(YcAllocHeader *ancestor, YcAllocHeader *header) {
    for (YcAllocHeader *current = header; current; current = current->owner) {
        if (current == ancestor) {
            return 1;
        }
    }
    return 0;
}

static void yc_detach_owner(YcAllocHeader *header) {
    if (!header || !header->owner) {
        return;
    }
    YcAllocHeader *owner = header->owner;
    if (header->sibling_prev) {
        header->sibling_prev->sibling_next = header->sibling_next;
    } else if (owner->first_child == header) {
        owner->first_child = header->sibling_next;
    }
    if (header->sibling_next) {
        header->sibling_next->sibling_prev = header->sibling_prev;
    }
    header->owner = NULL;
    header->sibling_prev = NULL;
    header->sibling_next = NULL;
}

static void yc_link_owner(YcAllocHeader *owner, YcAllocHeader *child) {
    yc_detach_owner(child);
    child->owner = owner;
    child->sibling_prev = NULL;
    child->sibling_next = owner->first_child;
    if (owner->first_child) {
        owner->first_child->sibling_prev = child;
    }
    owner->first_child = child;
    yc_move_graph_to_frame(child, owner->frame);
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
    yc_detach_owner(header);
    while (header->first_child) {
        yc_release_header(header->first_child);
    }
    yc_frame_unlink(header);
    yc_unlink(header);
    yc_registry_remove(header);
    header->magic = 0;
    free(header);
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
    header->owner = NULL;
    header->first_child = NULL;
    header->sibling_prev = NULL;
    header->sibling_next = NULL;
    yc_link(header);
    yc_frame_link(header, yc_current_frame);
    yc_registry_insert(header);
    return (void *)(header + 1);
}

void *yc_calloc(size_t count, size_t size) {
    if (size != 0 && count > SIZE_MAX / size) {
        return NULL;
    }
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

    if (child_header->owner == parent_header) {
        return;
    }
    if (yc_is_owner_ancestor(child_header, parent_header)) {
        return;
    }
    yc_link_owner(parent_header, child_header);
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

    YcAllocHeader *old_header = yc_header_from_ptr(old_child);
    if (old_header && old_header->owner == parent_header) {
        yc_detach_owner(old_header);
    }
    yc_attach_child(parent, new_child);
}

void *yc_move_to_parent(void *ptr) {
    return yc_move_to_ancestor(ptr, 1);
}

void *yc_move_to_ancestor(void *ptr, size_t levels) {
    YcAllocHeader *header = yc_header_containing_ptr(ptr);
    if (!header) {
        return ptr;
    }
    YcAllocHeader *root = yc_owner_root(header);
    if (!root || levels == 0 || yc_current_frame == 0) {
        return ptr;
    }
    uint32_t target = levels >= yc_current_frame ? 0 : yc_current_frame - (uint32_t)levels;
    if (root->frame > target) {
        yc_move_graph_to_frame(root, target);
    }
    return ptr;
}

void yc_move_frame_to_parent(void) {
    if (yc_current_frame == 0) {
        return;
    }
    while (yc_current_frame < yc_frame_heads_cap && yc_frame_heads[yc_current_frame]) {
        YcAllocHeader *header = yc_owner_root(yc_frame_heads[yc_current_frame]);
        yc_move_graph_to_frame(header, yc_current_frame - 1);
    }
}

void *yc_move_to_root(void *ptr) {
    YcAllocHeader *header = yc_header_containing_ptr(ptr);
    YcAllocHeader *root = yc_owner_root(header);
    if (!root || root->frame <= 1) {
        return ptr;
    }
    yc_move_graph_to_frame(root, 1);
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

typedef struct YcPathList {
    char **items;
    size_t len;
    size_t cap;
} YcPathList;

typedef struct YcVisitedDirectory {
    dev_t device;
    ino_t inode;
} YcVisitedDirectory;

typedef struct YcVisitedDirectoryList {
    YcVisitedDirectory *items;
    size_t len;
    size_t cap;
} YcVisitedDirectoryList;

static int yc_path_list_push(YcPathList *list, const char *path) {
    if (list->len == list->cap) {
        size_t next_cap = list->cap == 0 ? 32 : list->cap * 2;
        char **next = (char **)realloc(list->items, next_cap * sizeof(char *));
        if (!next) {
            return 0;
        }
        list->items = next;
        list->cap = next_cap;
    }
    size_t len = strlen(path);
    char *copy = (char *)malloc(len + 1);
    if (!copy) {
        return 0;
    }
    memcpy(copy, path, len + 1);
    list->items[list->len++] = copy;
    return 1;
}

static int yc_has_yc_extension(const char *path) {
    size_t len = strlen(path);
    return len >= 3 && path[len - 3] == '.' && path[len - 2] == 'y' && path[len - 1] == 'c';
}

static int yc_mark_directory_visited(YcVisitedDirectoryList *visited, const struct stat *info) {
    for (size_t i = 0; i < visited->len; ++i) {
        if (visited->items[i].device == info->st_dev && visited->items[i].inode == info->st_ino) {
            return 0;
        }
    }

    if (visited->len == visited->cap) {
        size_t next_cap = visited->cap == 0 ? 32 : visited->cap * 2;
        YcVisitedDirectory *next = (YcVisitedDirectory *)realloc(
            visited->items, next_cap * sizeof(YcVisitedDirectory));
        if (!next) {
            return -1;
        }
        visited->items = next;
        visited->cap = next_cap;
    }

    visited->items[visited->len].device = info->st_dev;
    visited->items[visited->len].inode = info->st_ino;
    visited->len++;
    return 1;
}

static int yc_collect_yc_paths(const char *dir, YcPathList *list, YcVisitedDirectoryList *visited) {
    struct stat dir_info;
    if (stat(dir, &dir_info) != 0 || !S_ISDIR(dir_info.st_mode)) {
        return 0;
    }

    int visit_result = yc_mark_directory_visited(visited, &dir_info);
    if (visit_result < 0) {
        return 0;
    }
    if (visit_result == 0) {
        return 1;
    }

    DIR *handle = opendir(dir);
    if (!handle) {
        return 0;
    }

    int ok = 1;
    struct dirent *entry;
    while ((entry = readdir(handle)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }

        size_t dir_len = strlen(dir);
        size_t name_len = strlen(entry->d_name);
        int needs_slash = dir_len > 0 && dir[dir_len - 1] != '/';
        size_t path_len = dir_len + (size_t)needs_slash + name_len;
        char *path = (char *)malloc(path_len + 1);
        if (!path) {
            ok = 0;
            break;
        }
        memcpy(path, dir, dir_len);
        size_t at = dir_len;
        if (needs_slash) {
            path[at++] = '/';
        }
        memcpy(path + at, entry->d_name, name_len + 1);

        struct stat info;
        /* Follow Bazel runfile links while the visited inode set prevents
           recursive directory symlink cycles. */
        if (stat(path, &info) == 0) {
            if (S_ISDIR(info.st_mode)) {
                if (!yc_collect_yc_paths(path, list, visited)) {
                    ok = 0;
                }
            } else if (S_ISREG(info.st_mode) && yc_has_yc_extension(path)) {
                if (!yc_path_list_push(list, path)) {
                    ok = 0;
                }
            }
        }
        free(path);
        if (!ok) {
            break;
        }
    }
    closedir(handle);
    return ok;
}

static int yc_compare_paths(const void *left, const void *right) {
    const char *const *a = (const char *const *)left;
    const char *const *b = (const char *const *)right;
    return strcmp(*a, *b);
}

static char *yc_fs_collect_yc_files(const char *start) {
    YcPathList list = {0};
    YcVisitedDirectoryList visited = {0};
    int ok = yc_collect_yc_paths(start, &list, &visited);
    free(visited.items);
    if (!ok) {
        for (size_t i = 0; i < list.len; ++i) {
            free(list.items[i]);
        }
        free(list.items);
        return NULL;
    }

    qsort(list.items, list.len, sizeof(char *), yc_compare_paths);
    size_t total = 1;
    for (size_t i = 0; i < list.len; ++i) {
        size_t len = strlen(list.items[i]);
        if (len > SIZE_MAX - total - 1) {
            for (size_t j = 0; j < list.len; ++j) {
                free(list.items[j]);
            }
            free(list.items);
            return NULL;
        }
        total += len + 1;
    }

    char *output = (char *)yc_alloc(total);
    if (!output) {
        for (size_t i = 0; i < list.len; ++i) {
            free(list.items[i]);
        }
        free(list.items);
        return NULL;
    }

    size_t at = 0;
    for (size_t i = 0; i < list.len; ++i) {
        size_t len = strlen(list.items[i]);
        memcpy(output + at, list.items[i], len);
        at += len;
        output[at++] = '\n';
        free(list.items[i]);
    }
    output[at] = '\0';
    free(list.items);
    return output;
}

char *yc_fs_find_yc_files_in(const char *root) {
    if (!root) {
        return NULL;
    }
    return yc_fs_collect_yc_files(root);
}

char *yc_fs_find_yc_files(const char *root) {
    if (!root) {
        return NULL;
    }

    size_t root_len = strlen(root);
    const char suffix[] = "/src";
    int has_src_suffix = root_len >= 4 && strcmp(root + root_len - 4, suffix) == 0;
    size_t start_len = root_len + (has_src_suffix ? 0 : sizeof(suffix) - 1);
    char *start = (char *)malloc(start_len + 1);
    if (!start) {
        return NULL;
    }
    memcpy(start, root, root_len);
    if (!has_src_suffix) {
        memcpy(start + root_len, suffix, sizeof(suffix));
    } else {
        start[root_len] = '\0';
    }
    char *result = yc_fs_collect_yc_files(start);
    free(start);
    return result;
}

char *yc_executable_dir(void) {
    char buffer[4096];
    size_t length = 0;
#if defined(__APPLE__)
    uint32_t size = (uint32_t)sizeof(buffer);
    if (_NSGetExecutablePath(buffer, &size) != 0) {
        return NULL;
    }
    length = strlen(buffer);
#elif defined(__linux__)
    ssize_t got = readlink("/proc/self/exe", buffer, sizeof(buffer) - 1);
    if (got <= 0) {
        return NULL;
    }
    length = (size_t)got;
    buffer[length] = '\0';
#else
    return NULL;
#endif
    while (length > 0 && buffer[length - 1] != '/') {
        length--;
    }
    if (length == 0) {
        return yc_keep_string(".");
    }
    while (length > 1 && buffer[length - 1] == '/') {
        length--;
    }
    char *out = (char *)yc_alloc(length + 1);
    if (!out) {
        return NULL;
    }
    memcpy(out, buffer, length);
    out[length] = '\0';
    return out;
}

static char **yc_make_argv(const char *program, const char *const *args, size_t count) {
    if (count > (SIZE_MAX / sizeof(char *)) - 2) {
        return NULL;
    }
    char **argv = (char **)calloc(count + 2, sizeof(char *));
    if (!argv) {
        return NULL;
    }
    argv[0] = (char *)program;
    for (size_t i = 0; i < count; ++i) {
        argv[i + 1] = (char *)args[i];
    }
    return argv;
}

int yc_process_run(const char *program, const char *const *args, size_t count) {
    if (!program) {
        return 127;
    }
    char **argv = yc_make_argv(program, args, count);
    if (!argv) {
        return 127;
    }

    pid_t child = fork();
    if (child == 0) {
        execvp(program, argv);
        _exit(127);
    }
    free(argv);
    if (child < 0) {
        return 127;
    }

    int child_status = 0;
    while (waitpid(child, &child_status, 0) < 0) {
        if (errno != EINTR) {
            return 127;
        }
    }
    if (WIFEXITED(child_status)) {
        return WEXITSTATUS(child_status);
    }
    if (WIFSIGNALED(child_status)) {
        return 128 + WTERMSIG(child_status);
    }
    return 127;
}

char *yc_process_capture(const char *program, const char *const *args, size_t count, int *status) {
    if (status) {
        *status = 127;
    }
    if (!program) {
        return NULL;
    }

    int pipes[2];
    if (pipe(pipes) != 0) {
        return NULL;
    }
    char **argv = yc_make_argv(program, args, count);
    if (!argv) {
        close(pipes[0]);
        close(pipes[1]);
        return NULL;
    }

    pid_t child = fork();
    if (child == 0) {
        close(pipes[0]);
        if (dup2(pipes[1], STDOUT_FILENO) < 0) {
            _exit(127);
        }
        close(pipes[1]);
        execvp(program, argv);
        _exit(127);
    }
    free(argv);
    close(pipes[1]);
    if (child < 0) {
        close(pipes[0]);
        return NULL;
    }

    size_t cap = 4096;
    size_t len = 0;
    char *buffer = (char *)malloc(cap);
    if (!buffer) {
        close(pipes[0]);
        waitpid(child, NULL, 0);
        return NULL;
    }

    for (;;) {
        if (len + 2048 + 1 > cap) {
            size_t next_cap = cap * 2;
            char *next = (char *)realloc(buffer, next_cap);
            if (!next) {
                free(buffer);
                close(pipes[0]);
                waitpid(child, NULL, 0);
                return NULL;
            }
            buffer = next;
            cap = next_cap;
        }
        ssize_t got = read(pipes[0], buffer + len, cap - len - 1);
        if (got > 0) {
            len += (size_t)got;
            continue;
        }
        if (got < 0 && errno == EINTR) {
            continue;
        }
        break;
    }
    close(pipes[0]);

    int child_status = 0;
    while (waitpid(child, &child_status, 0) < 0 && errno == EINTR) {
    }
    int exit_status = 127;
    if (WIFEXITED(child_status)) {
        exit_status = WEXITSTATUS(child_status);
    } else if (WIFSIGNALED(child_status)) {
        exit_status = 128 + WTERMSIG(child_status);
    }
    if (status) {
        *status = exit_status;
    }

    char *output = (char *)yc_alloc(len + 1);
    if (output) {
        memcpy(output, buffer, len);
        output[len] = '\0';
    }
    free(buffer);
    return output;
}

static char **yc_unpack_argv(const char *program, const char *packed_args, size_t packed_size, size_t *count_out) {
    size_t count = 0;
    size_t at = 0;
    while (at < packed_size) {
        size_t remaining = packed_size - at;
        size_t len = 0;
        while (len < remaining && packed_args[at + len] != '\0') {
            len++;
        }
        if (len == remaining) {
            return NULL;
        }
        count++;
        at += len + 1;
    }

    char **argv = (char **)calloc(count + 2, sizeof(char *));
    if (!argv) {
        return NULL;
    }
    argv[0] = (char *)program;
    at = 0;
    for (size_t i = 0; i < count; ++i) {
        argv[i + 1] = (char *)(packed_args + at);
        at += strlen(packed_args + at) + 1;
    }
    if (count_out) {
        *count_out = count;
    }
    return argv;
}

int yc_process_run_packed(const char *program, const char *packed_args, size_t packed_size) {
    if (!program || (!packed_args && packed_size != 0)) {
        return 127;
    }
    size_t count = 0;
    char **argv = yc_unpack_argv(program, packed_args, packed_size, &count);
    if (!argv) {
        return 127;
    }
    int status = yc_process_run(program, (const char *const *)(argv + 1), count);
    free(argv);
    return status;
}

char *yc_process_capture_packed(const char *program, const char *packed_args, size_t packed_size, int *status) {
    if (!program || (!packed_args && packed_size != 0)) {
        if (status) {
            *status = 127;
        }
        return NULL;
    }
    size_t count = 0;
    char **argv = yc_unpack_argv(program, packed_args, packed_size, &count);
    if (!argv) {
        if (status) {
            *status = 127;
        }
        return NULL;
    }
    char *output = yc_process_capture(program, (const char *const *)(argv + 1), count, status);
    free(argv);
    return output;
}

typedef struct YcArgVector {
    char **items;
    size_t len;
    size_t cap;
} YcArgVector;

static void yc_arg_vector_destroy(YcArgVector *vector) {
    if (!vector) {
        return;
    }
    for (size_t i = 0; i < vector->len; ++i) {
        free(vector->items[i]);
    }
    free(vector->items);
    vector->items = NULL;
    vector->len = 0;
    vector->cap = 0;
}

static int yc_arg_vector_push(YcArgVector *vector, const char *text, size_t len) {
    if (!vector || !text || len > SIZE_MAX - 1) {
        return 0;
    }
    if (vector->len == vector->cap) {
        size_t next_cap = vector->cap ? vector->cap * 2 : 16;
        if (next_cap < vector->cap || next_cap > SIZE_MAX / sizeof(char *)) {
            return 0;
        }
        char **next = (char **)realloc(vector->items, next_cap * sizeof(char *));
        if (!next) {
            return 0;
        }
        vector->items = next;
        vector->cap = next_cap;
    }
    char *copy = (char *)malloc(len + 1);
    if (!copy) {
        return 0;
    }
    memcpy(copy, text, len);
    copy[len] = '\0';
    vector->items[vector->len++] = copy;
    return 1;
}

static int yc_arg_vector_push_text(YcArgVector *vector, const char *text) {
    return text && yc_arg_vector_push(vector, text, strlen(text));
}

static int yc_arg_vector_push_words(YcArgVector *vector, const char *words) {
    if (!words) {
        return 1;
    }
    const unsigned char *at = (const unsigned char *)words;
    while (*at) {
        while (*at == ' ' || *at == '\t' || *at == '\r' || *at == '\n') {
            ++at;
        }
        const unsigned char *start = at;
        while (*at && *at != ' ' && *at != '\t' && *at != '\r' && *at != '\n') {
            ++at;
        }
        if (at != start && !yc_arg_vector_push(vector, (const char *)start, (size_t)(at - start))) {
            return 0;
        }
    }
    return 1;
}

int yc_native_link(const char *clang, const char *llvm_config, const char *linkflags,
                   const char *object_file, const char *runtime_object, const char *output_file) {
    if (!clang || !llvm_config || !object_file || !runtime_object || !output_file) {
        return 127;
    }
    const char *const llvm_args[] = {"--ldflags", "--libs", "core", "--system-libs"};
    int config_status = 127;
    char *llvm_flags = yc_process_capture(llvm_config, llvm_args, 4, &config_status);
    if (config_status != 0 || !llvm_flags) {
        yc_release(llvm_flags);
        return config_status ? config_status : 127;
    }

    YcArgVector args = {0};
    int ok = yc_arg_vector_push_words(&args, linkflags) &&
             yc_arg_vector_push_text(&args, object_file) &&
             yc_arg_vector_push_text(&args, runtime_object) &&
             yc_arg_vector_push_text(&args, "-o") &&
             yc_arg_vector_push_text(&args, output_file) &&
             yc_arg_vector_push_words(&args, llvm_flags) &&
             yc_arg_vector_push_text(&args, "-lm");
    int status = ok ? yc_process_run(clang, (const char *const *)args.items, args.len) : 127;
    yc_arg_vector_destroy(&args);
    yc_release(llvm_flags);
    return status;
}
