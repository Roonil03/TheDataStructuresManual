#include <stdio.h>
#include <stdlib.h>

#define ORDER 3

typedef struct BPlusNode {
    int is_leaf;
    int num_keys;
    int keys[ORDER - 1];
    struct BPlusNode *pointers[ORDER];
    struct BPlusNode *next;
} BPlusNode;

BPlusNode *root = NULL;

BPlusNode* create_node(int is_leaf) {
    BPlusNode *node = malloc(sizeof(BPlusNode));
    node->is_leaf = is_leaf;
    node->num_keys = 0;
    node->next = NULL;
    for (int i = 0; i < ORDER; i++) {
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
    if (left == root) {
        BPlusNode *new_root = create_node(0);
        new_root->keys[0] = key;
        new_root->pointers[0] = left;
        new_root->pointers[1] = right;
        new_root->num_keys = 1;
        root = new_root;
    }
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
    scanf("%d", &n);
    
    for (int i = 0; i < n; i++) {
        scanf("%d", &key);
        insert(key);
    }
    
    print_tree();
    printf("\n");
    
    return 0;
}
