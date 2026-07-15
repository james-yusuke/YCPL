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

/* Portable compiler support. Returned text is managed by the YCPL runtime. */
char *yc_fs_find_yc_files(const char *root);
int yc_process_run(const char *program, const char *const *args, size_t count);
char *yc_process_capture(const char *program, const char *const *args, size_t count, int *status);
int yc_process_run_packed(const char *program, const char *packed_args, size_t packed_size);
char *yc_process_capture_packed(const char *program, const char *packed_args, size_t packed_size, int *status);
int yc_native_link(const char *clang, const char *llvm_config, const char *linkflags,
                   const char *object_file, const char *runtime_object, const char *output_file);

#ifdef __cplusplus
}
#endif
