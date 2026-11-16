/* B-tree insertion by splitting full children before descent. */
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

typedef struct BTreeNode {
    int *keys;
    struct BTreeNode **children;
    int count;
    int leaf;
    int degree;
} BTreeNode;

BTreeNode* createNode(int degree, int leaf) {
    BTreeNode* node = malloc(sizeof(BTreeNode));
    if (!node) exit(EXIT_FAILURE);
    node->keys = malloc((2 * degree - 1) * sizeof(int));
    node->children = malloc(2 * degree * sizeof(BTreeNode*));
    if (!node->keys || !node->children) exit(EXIT_FAILURE);
    node->count = 0;
    node->leaf = leaf;
    node->degree = degree;
    return node;
}

void splitChild(BTreeNode* parent, int index);

void insertNonFull(BTreeNode* node, int key) {
    int i = node->count - 1;

    if (node->leaf) {
        while (i >= 0 && node->keys[i] > key) {
            node->keys[i + 1] = node->keys[i];
            i--;
        }
        node->keys[i + 1] = key;
        node->count++;
    } else {
        while (i >= 0 && node->keys[i] > key) {
            i--;
        }
        i++;
        if (node->children[i]->count == 2 * node->degree - 1) {
            splitChild(node, i);
            if (node->keys[i] < key) {
                i++;
            }
        }
        insertNonFull(node->children[i], key);
    }
}

void splitChild(BTreeNode* parent, int index) {
    BTreeNode* full = parent->children[index];
    BTreeNode* newNode = createNode(full->degree, full->leaf);

    newNode->count = parent->degree - 1;

    for (int j = 0; j < parent->degree - 1; j++) {
        newNode->keys[j] = full->keys[j + parent->degree];
    }

    if (!full->leaf) {
        for (int j = 0; j < parent->degree; j++) {
            newNode->children[j] = full->children[j + parent->degree];
        }
    }

    full->count = parent->degree - 1;

    for (int j = parent->count; j >= index + 1; j--) {
        parent->children[j + 1] = parent->children[j];
    }
    parent->children[index + 1] = newNode;

    for (int j = parent->count - 1; j >= index; j--) {
        parent->keys[j + 1] = parent->keys[j];
    }
    parent->keys[index] = full->keys[parent->degree - 1];
    parent->count++;
}

BTreeNode* insert(BTreeNode* root, int key, int degree) {
    if (root->count == 2 * degree - 1) {
        BTreeNode* newRoot = createNode(degree, 0);
        newRoot->children[0] = root;
        splitChild(newRoot, 0);
        insertNonFull(newRoot, key);
        return newRoot;
    } else {
        insertNonFull(root, key);
        return root;
    }
}

void traverse(BTreeNode* root) {
    if (root) {
        int i;
        for (i = 0; i < root->count; i++) {
            if (!root->leaf) {
                traverse(root->children[i]);
            }
            printf("%d ", root->keys[i]);
        }
        if (!root->leaf) {
            traverse(root->children[i]);
        }
    }
}

void free_tree(BTreeNode *node) {
    if (!node->leaf)
        for (int i = 0; i <= node->count; i++) free_tree(node->children[i]);
    free(node->keys);
    free(node->children);
    free(node);
}

int main() {
    int t, n;
    if (scanf("%d", &t) != 1 || t < 2 || t > INT_MAX / 2) return EXIT_FAILURE;
    if (scanf("%d", &n) != 1 || n < 0) return EXIT_FAILURE;

    BTreeNode* root = createNode(t, 1);

    for (int i = 0; i < n; i++) {
        int key;
        if (scanf("%d", &key) != 1) { free_tree(root); return EXIT_FAILURE; }
        root = insert(root, key, t);
    }

    traverse(root);
    printf("\n");

    free_tree(root);
    return 0;
}
