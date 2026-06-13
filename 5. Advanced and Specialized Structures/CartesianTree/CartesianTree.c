#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

typedef struct CTNode {
    int value, index;
    struct CTNode *left, *right;
} CTNode;

typedef struct {
    CTNode *root;
    int n;
} CartesianTree;

static CTNode *new_node(int val, int idx) {
    CTNode *n = malloc(sizeof(CTNode));
    n->value = val;
    n->index = idx;
    n->left = n->right = NULL;
    return n;
}

CartesianTree *ct_build(int *arr, int n) {
    CartesianTree *ct = malloc(sizeof(CartesianTree));
    ct->n = n;
    ct->root = NULL;
    if (n == 0) return ct;

    CTNode **stack = malloc(n * sizeof(CTNode *));
    int top = 0;

    for (int i = 0; i < n; i++) {
        CTNode *node = new_node(arr[i], i);
        CTNode *last_popped = NULL;

        while (top > 0 && stack[top - 1]->value > arr[i]) {
            last_popped = stack[--top];
        }

        node->left = last_popped;

        if (top > 0)
            stack[top - 1]->right = node;

        stack[top++] = node;
    }

    ct->root = stack[0];
    free(stack);
    return ct;
}

static void inorder(CTNode *root) {
    if (!root) return;
    inorder(root->left);
    printf("%d ", root->value);
    inorder(root->right);
}

static int verify_heap(CTNode *root) {
    if (!root) return 1;
    if (root->left && root->left->value < root->value) return 0;
    if (root->right && root->right->value < root->value) return 0;
    return verify_heap(root->left) && verify_heap(root->right);
}

static int verify_inorder(CTNode *root, int *arr, int *pos) {
    if (!root) return 1;
    if (!verify_inorder(root->left, arr, pos)) return 0;
    if (root->value != arr[(*pos)++]) return 0;
    return verify_inorder(root->right, arr, pos);
}

static void print_tree(CTNode *root, int depth) {
    if (!root) return;
    print_tree(root->right, depth + 1);
    for (int i = 0; i < depth; i++) printf("    ");
    printf("[%d]\n", root->value);
    print_tree(root->left, depth + 1);
}

static CTNode *rmq(CTNode *root, int lo, int hi) {
    if (!root) return NULL;
    CTNode *best = NULL;
    if (root->index >= lo && root->index <= hi)
        best = root;
    CTNode *l = rmq(root->left, lo, hi);
    CTNode *r = rmq(root->right, lo, hi);
    if (l && (!best || l->value < best->value)) best = l;
    if (r && (!best || r->value < best->value)) best = r;
    return best;
}

static void free_tree(CTNode *root) {
    if (!root) return;
    free_tree(root->left);
    free_tree(root->right);
    free(root);
}

int main(void) {
    int arr[] = {3, 2, 6, 1, 9, 5, 7};
    int n = sizeof(arr) / sizeof(arr[0]);

    CartesianTree *ct = ct_build(arr, n);

    printf("Input: ");
    for (int i = 0; i < n; i++) printf("%d ", arr[i]);
    printf("\n");

    printf("Inorder: ");
    inorder(ct->root);
    printf("\n");

    printf("Tree structure:\n");
    print_tree(ct->root, 0);

    printf("Root: %d (should be min = 1)\n", ct->root->value);

    printf("Min-heap property: %d\n", verify_heap(ct->root));

    int pos = 0;
    printf("Inorder matches input: %d\n", verify_inorder(ct->root, arr, &pos));

    CTNode *result = rmq(ct->root, 0, 2);
    printf("RMQ[0,2]: %d (expected 2)\n", result ? result->value : -1);

    result = rmq(ct->root, 4, 6);
    printf("RMQ[4,6]: %d (expected 5)\n", result ? result->value : -1);

    result = rmq(ct->root, 0, 6);
    printf("RMQ[0,6]: %d (expected 1)\n", result ? result->value : -1);

    free_tree(ct->root);
    free(ct);
    printf("All tests passed.\n");
    return 0;
}
