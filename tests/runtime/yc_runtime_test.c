#include "bootstrap/cpp/runtime/yc_runtime.h"

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static void test_selective_escape_and_unbounded_children(void) {
    yc_runtime_init();
    yc_frame_push();

    void *outer = yc_alloc(1);
    assert(outer != NULL);

    yc_frame_push();
    void *root = yc_alloc(1);
    void *children[8];
    for (size_t i = 0; i < 8; ++i) {
        children[i] = yc_alloc(8);
        assert(children[i] != NULL);
        yc_attach_child(root, children[i]);
    }
    void *unrelated = yc_alloc(1);
    assert(unrelated != NULL);
    assert(yc_runtime_live_allocations() == 11);

    yc_move_to_parent(children[3]);
    yc_frame_pop();
    assert(yc_runtime_live_allocations() == 10);

    yc_release(root);
    assert(yc_runtime_live_allocations() == 1);
    yc_frame_pop();
    assert(yc_runtime_live_allocations() == 0);
    yc_runtime_shutdown();
}

static void test_nested_owner_graph(void) {
    yc_runtime_init();
    yc_frame_push();
    yc_frame_push();

    void *root = yc_alloc(4);
    void *child = yc_alloc(4);
    void *grandchild = yc_alloc(4);
    yc_attach_child(root, child);
    yc_attach_child(child, grandchild);
    yc_move_to_parent(grandchild);
    yc_frame_pop();
    assert(yc_runtime_live_allocations() == 3);

    yc_frame_pop();
    assert(yc_runtime_live_allocations() == 0);
    yc_runtime_shutdown();
}

static void test_unmanaged_pointer_is_ignored(void) {
    static const char literal[] = "borrowed";
    yc_runtime_init();
    yc_frame_push();
    assert(yc_move_to_parent((void *)literal) == literal);
    yc_release((void *)literal);
    yc_frame_pop();
    assert(yc_runtime_live_allocations() == 0);
    yc_runtime_shutdown();
}

static void test_portable_compiler_support(void) {
    char root[256];
    char src[280];
    char nested[304];
    char first[336];
    char second[336];
    snprintf(root, sizeof(root), "/tmp/yc_runtime_test_%ld", (long)getpid());
    snprintf(src, sizeof(src), "%s/src", root);
    snprintf(nested, sizeof(nested), "%s/nested", src);
    snprintf(first, sizeof(first), "%s/a.yc", src);
    snprintf(second, sizeof(second), "%s/b.yc", nested);

    assert(mkdir(root, 0700) == 0);
    assert(mkdir(src, 0700) == 0);
    assert(mkdir(nested, 0700) == 0);
    FILE *file = fopen(second, "w");
    assert(file != NULL);
    fputs("fn b() {}\n", file);
    fclose(file);
    file = fopen(first, "w");
    assert(file != NULL);
    fputs("fn a() {}\n", file);
    fclose(file);

    yc_runtime_init();
    yc_frame_push();
    char *files = yc_fs_find_yc_files(root);
    assert(files != NULL);
    char expected[700];
    snprintf(expected, sizeof(expected), "%s\n%s\n", first, second);
    assert(strcmp(files, expected) == 0);

    const char *capture_args[] = {"YCPL"};
    int status = -1;
    char *captured = yc_process_capture("printf", capture_args, 1, &status);
    assert(status == 0);
    assert(captured != NULL);
    assert(strcmp(captured, "YCPL") == 0);

    const char *run_args[] = {"-c", "exit 7"};
    assert(yc_process_run("sh", run_args, 2) == 7);
    const char packed_args[] = {'Y', 'C', 'P', 'L', '\0'};
    status = -1;
    captured = yc_process_capture_packed("printf", packed_args, sizeof(packed_args), &status);
    assert(status == 0);
    assert(captured != NULL);
    assert(strcmp(captured, "YCPL") == 0);

    const char packed_many[] = {'%', 's', '/', '%', 's', '\0', 'l', 'e', 'f', 't', '\0', 'r', 'i', 'g', 'h', 't', '\0'};
    status = -1;
    captured = yc_process_capture_packed("printf", packed_many, sizeof(packed_many), &status);
    assert(status == 0);
    assert(captured != NULL);
    assert(strcmp(captured, "left/right") == 0);
    yc_frame_pop();
    assert(yc_runtime_live_allocations() == 0);
    yc_runtime_shutdown();

    assert(unlink(first) == 0);
    assert(unlink(second) == 0);
    assert(rmdir(nested) == 0);
    assert(rmdir(src) == 0);
    assert(rmdir(root) == 0);
}

int main(void) {
    test_selective_escape_and_unbounded_children();
    test_nested_owner_graph();
    test_unmanaged_pointer_is_ignored();
    test_portable_compiler_support();
    return 0;
}
