#include <stdio.h>
#include <stdlib.h>

#define RED 1
#define BLACK 0

struct Node {
    int key;
    int color;
    struct Node* left;
    struct Node* right;
    struct Node* parent;
};

struct Node* NIL;

struct Node* createNode(int key) {
    struct Node* node = malloc(sizeof(struct Node));
    node->key = key;
    node->color = RED;
    node->left = NIL;
    node->right = NIL;
    node->parent = NIL;
    return node;
}

void leftRotate(struct Node** root, struct Node* x) {
    struct Node* y = x->right;
    x->right = y->left;
    if (y->left != NIL)
        y->left->parent = x;
    y->parent = x->parent;
    if (x->parent == NIL)
        *root = y;
    else if (x == x->parent->left)
        x->parent->left = y;
    else
        x->parent->right = y;
    y->left = x;
    x->parent = y;
}

void rightRotate(struct Node** root, struct Node* y) {
    struct Node* x = y->left;
    y->left = x->right;
    if (x->right != NIL)
        x->right->parent = y;
    x->parent = y->parent;
    if (y->parent == NIL)
        *root = x;
    else if (y == y->parent->right)
        y->parent->right = x;
    else
        y->parent->left = x;
    x->right = y;
    y->parent = x;
}

void insertFixup(struct Node** root, struct Node* z) {
    while (z->parent->color == RED) {
        if (z->parent == z->parent->parent->left) {
            struct Node* y = z->parent->parent->right;
            if (y->color == RED) {
                z->parent->color = BLACK;
                y->color = BLACK;
                z->parent->parent->color = RED;
                z = z->parent->parent;
            } else {
                if (z == z->parent->right) {
                    z = z->parent;
                    leftRotate(root, z);
                }
                z->parent->color = BLACK;
                z->parent->parent->color = RED;
                rightRotate(root, z->parent->parent);
            }
        } else {
            struct Node* y = z->parent->parent->left;
            if (y->color == RED) {
                z->parent->color = BLACK;
                y->color = BLACK;
                z->parent->parent->color = RED;
                z = z->parent->parent;
            } else {
                if (z == z->parent->left) {
                    z = z->parent;
                    rightRotate(root, z);
                }
                z->parent->color = BLACK;
                z->parent->parent->color = RED;
                leftRotate(root, z->parent->parent);
            }
        }
    }
    (*root)->color = BLACK;
}

void insert(struct Node** root, int key) {
    struct Node* z = createNode(key);
    struct Node* y = NIL;
    struct Node* x = *root;
    
    while (x != NIL) {
        y = x;
        if (z->key < x->key)
            x = x->left;
        else
            x = x->right;
    }
    z->parent = y;
    if (y == NIL)
        *root = z;
    else if (z->key < y->key)
        y->left = z;
    else
        y->right = z;
    
    if (z->parent == NIL) {
        z->color = BLACK;
        return;
    }
    if (z->parent->parent == NIL)
        return;
    
    insertFixup(root, z);
}

void inorder(struct Node* root) {
    if (root != NIL) {
        inorder(root->left);
        printf("%d ", root->key);
        inorder(root->right);
    }
}

int main() {
    NIL = malloc(sizeof(struct Node));
    NIL->color = BLACK;
    NIL->left = NIL->right = NIL->parent = NIL;
    
    struct Node* root = NIL;
    int key;
    
    while (scanf("%d", &key) == 1) {
        insert(&root, key);
    }
    
    inorder(root);
    printf("\n");
    
    return 0;
}
