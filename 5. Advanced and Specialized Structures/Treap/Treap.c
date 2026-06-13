#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct TreapNode {
    int key, priority;
    struct TreapNode *left, *right;
} TreapNode;

typedef struct {
    TreapNode *root;
} Treap;

static TreapNode *new_node(int key) {
    TreapNode *n = malloc(sizeof(TreapNode));
    n->key = key;
    n->priority = rand();
    n->left = n->right = NULL;
    return n;
}

static TreapNode *rotate_right(TreapNode *y) {
    TreapNode *x = y->left;
    y->left = x->right;
    x->right = y;
    return x;
}

static TreapNode *rotate_left(TreapNode *x) {
    TreapNode *y = x->right;
    x->right = y->left;
    y->left = x;
    return y;
}

static TreapNode *insert(TreapNode *root, int key) {
    if (!root) return new_node(key);
    if (key < root->key) {
        root->left = insert(root->left, key);
        if (root->left->priority > root->priority)
            root = rotate_right(root);
    } else if (key > root->key) {
        root->right = insert(root->right, key);
        if (root->right->priority > root->priority)
            root = rotate_left(root);
    }
    return root;
}

static TreapNode *delete(TreapNode *root, int key) {
    if (!root) return NULL;
    if (key < root->key)
        root->left = delete(root->left, key);
    else if (key > root->key)
        root->right = delete(root->right, key);
    else {
        if (!root->left) {
            TreapNode *tmp = root->right;
            free(root);
            return tmp;
        }
        if (!root->right) {
            TreapNode *tmp = root->left;
            free(root);
            return tmp;
        }
        if (root->left->priority > root->right->priority) {
            root = rotate_right(root);
            root->right = delete(root->right, key);
        } else {
            root = rotate_left(root);
            root->left = delete(root->left, key);
        }
    }
    return root;
}

static TreapNode *search(TreapNode *root, int key) {
    if (!root || root->key == key) return root;
    if (key < root->key) return search(root->left, key);
    return search(root->right, key);
}

static void inorder(TreapNode *root) {
    if (!root) return;
    inorder(root->left);
    printf("%d ", root->key);
    inorder(root->right);
}

static int height(TreapNode *root) {
    if (!root) return 0;
    int l = height(root->left);
    int r = height(root->right);
    return 1 + (l > r ? l : r);
}

static void free_tree(TreapNode *root) {
    if (!root) return;
    free_tree(root->left);
    free_tree(root->right);
    free(root);
}

static int verify_bst(TreapNode *root, int lo, int hi) {
    if (!root) return 1;
    if (root->key <= lo || root->key >= hi) return 0;
    return verify_bst(root->left, lo, root->key) &&
           verify_bst(root->right, root->key, hi);
}

static int verify_heap(TreapNode *root) {
    if (!root) return 1;
    if (root->left && root->left->priority > root->priority) return 0;
    if (root->right && root->right->priority > root->priority) return 0;
    return verify_heap(root->left) && verify_heap(root->right);
}

int main(void) {
    srand(42);
    Treap t = {NULL};

    int keys[] = {50, 30, 70, 20, 40, 60, 80, 10, 35, 55};
    int n = sizeof(keys) / sizeof(keys[0]);

    for (int i = 0; i < n; i++)
        t.root = insert(t.root, keys[i]);

    printf("Inorder: ");
    inorder(t.root);
    printf("\n");

    printf("Height: %d\n", height(t.root));
    printf("BST property: %d\n", verify_bst(t.root, -1, 10000));
    printf("Heap property: %d\n", verify_heap(t.root));

    printf("Search 40: %s\n", search(t.root, 40) ? "found" : "not found");
    printf("Search 99: %s\n", search(t.root, 99) ? "found" : "not found");

    t.root = delete(t.root, 30);
    t.root = delete(t.root, 70);
    printf("After deleting 30, 70:\n");
    printf("Inorder: ");
    inorder(t.root);
    printf("\n");
    printf("Search 30: %s\n", search(t.root, 30) ? "found" : "not found");
    printf("BST property: %d\n", verify_bst(t.root, -1, 10000));
    printf("Heap property: %d\n", verify_heap(t.root));

    free_tree(t.root);
    printf("All tests passed.\n");
    return 0;
}
