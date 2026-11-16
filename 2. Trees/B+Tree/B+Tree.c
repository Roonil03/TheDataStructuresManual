/* Order-3 B+ tree insertion with linked leaves and upward split propagation. */
#include <stdio.h>
#include <stdlib.h>

#define ORDER 3

typedef struct BPlusNode {
    int is_leaf;
    int num_keys;
    int keys[ORDER];
    struct BPlusNode *pointers[ORDER + 1];
    struct BPlusNode *parent;
    struct BPlusNode *next;
} BPlusNode;

BPlusNode *root = NULL;

BPlusNode* create_node(int is_leaf) {
    BPlusNode *node = malloc(sizeof(BPlusNode));
    if (!node) exit(EXIT_FAILURE);
    node->is_leaf = is_leaf;
    node->num_keys = 0;
    node->next = NULL;
    node->parent = NULL;
    for (int i = 0; i <= ORDER; i++) {
        node->pointers[i] = NULL;
    }
    return node;
}

BPlusNode* find_leaf(BPlusNode *root, int key) {
    if (root == NULL) return NULL;

    BPlusNode *current = root;
    while (!current->is_leaf) {
        int i = 0;
        while (i < current->num_keys && key >= current->keys[i]) {
            i++;
        }
        current = current->pointers[i];
    }
    return current;
}

void insert_into_leaf(BPlusNode *leaf, int key) {
    if (leaf->num_keys == 0) {
        leaf->keys[0] = key;
        leaf->num_keys = 1;
        return;
    }

    int i = leaf->num_keys - 1;
    while (i >= 0 && leaf->keys[i] > key) {
        leaf->keys[i + 1] = leaf->keys[i];
        i--;
    }
    leaf->keys[i + 1] = key;
    leaf->num_keys++;
}

BPlusNode* split_leaf(BPlusNode *leaf) {
    BPlusNode *new_leaf = create_node(1);
    int split_point = (ORDER - 1) / 2;

    new_leaf->num_keys = leaf->num_keys - split_point;
    for (int i = 0; i < new_leaf->num_keys; i++) {
        new_leaf->keys[i] = leaf->keys[split_point + i];
    }

    leaf->num_keys = split_point;
    new_leaf->next = leaf->next;
    leaf->next = new_leaf;

    return new_leaf;
}

void insert_into_parent(BPlusNode *left, int key, BPlusNode *right) {
    BPlusNode *parent = left->parent;
    if (!parent) {
        parent = create_node(0);
        parent->keys[0] = key;
        parent->pointers[0] = left;
        parent->pointers[1] = right;
        parent->num_keys = 1;
        left->parent = right->parent = parent;
        root = parent;
        return;
    }
    int index = 0;
    while (parent->pointers[index] != left) index++;
    for (int i = parent->num_keys; i > index; i--) {
        parent->keys[i] = parent->keys[i - 1];
        parent->pointers[i + 1] = parent->pointers[i];
    }
    parent->keys[index] = key;
    parent->pointers[index + 1] = right;
    right->parent = parent;
    if (++parent->num_keys < ORDER) return;

    int middle = parent->num_keys / 2;
    int promoted = parent->keys[middle];
    BPlusNode *sibling = create_node(0);
    sibling->parent = parent->parent;
    sibling->num_keys = parent->num_keys - middle - 1;
    for (int i = 0; i < sibling->num_keys; i++)
        sibling->keys[i] = parent->keys[middle + 1 + i];
    for (int i = 0; i <= sibling->num_keys; i++) {
        sibling->pointers[i] = parent->pointers[middle + 1 + i];
        sibling->pointers[i]->parent = sibling;
    }
    parent->num_keys = middle;
    insert_into_parent(parent, promoted, sibling);
}

void free_tree(BPlusNode *node) {
    if (!node) return;
    if (!node->is_leaf)
        for (int i = 0; i <= node->num_keys; i++) free_tree(node->pointers[i]);
    free(node);
}

void insert(int key) {
    if (root == NULL) {
        root = create_node(1);
        root->keys[0] = key;
        root->num_keys = 1;
        return;
    }

    BPlusNode *leaf = find_leaf(root, key);

    for (int i = 0; i < leaf->num_keys; i++) {
        if (leaf->keys[i] == key) return;
    }

    if (leaf->num_keys < ORDER - 1) {
        insert_into_leaf(leaf, key);
    } else {
        insert_into_leaf(leaf, key);
        BPlusNode *new_leaf = split_leaf(leaf);
        int new_key = new_leaf->keys[0];
        insert_into_parent(leaf, new_key, new_leaf);
    }
}

void print_tree() {
    if (root == NULL) return;

    BPlusNode *current = root;
    while (!current->is_leaf) {
        current = current->pointers[0];
    }

    while (current != NULL) {
        for (int i = 0; i < current->num_keys; i++) {
            printf("%d ", current->keys[i]);
        }
        current = current->next;
    }
}

int main() {
    int n, key;
    if (scanf("%d", &n) != 1 || n < 0) return EXIT_FAILURE;

    for (int i = 0; i < n; i++) {
        if (scanf("%d", &key) != 1) { free_tree(root); return EXIT_FAILURE; }
        insert(key);
    }

    print_tree();
    printf("\n");

    free_tree(root);
    return 0;
}
