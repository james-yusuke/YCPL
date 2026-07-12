#pragma once

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

void yc_runtime_init(void);
void yc_runtime_shutdown(void);
void yc_frame_push(void);
void yc_frame_pop(void);
void *yc_alloc(size_t size);
void *yc_calloc(size_t count, size_t size);
void *yc_realloc(void *ptr, size_t size);
void yc_release(void *ptr);
void yc_attach_child(void *parent, void *child);
void yc_replace_child(void *parent, void *old_child, void *new_child);
void *yc_move_to_parent(void *ptr);
void *yc_move_to_ancestor(void *ptr, size_t levels);
void yc_move_frame_to_parent(void);
void *yc_move_to_root(void *ptr);
char *yc_keep_string(const char *ptr);
size_t yc_runtime_live_allocations(void);

#ifdef __cplusplus
}
#endif
