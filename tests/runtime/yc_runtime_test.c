#include "bootstrap/cpp/runtime/yc_runtime.h"

#include <assert.h>
#include <stddef.h>

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

int main(void) {
    test_selective_escape_and_unbounded_children();
    test_nested_owner_graph();
    test_unmanaged_pointer_is_ignored();
    return 0;
}
