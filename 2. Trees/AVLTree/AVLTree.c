#include <stdio.h>
#include <stdlib.h>

struct Node {
    int key;
    int height;
    struct Node* left;
    struct Node* right;
};

int height(struct Node* node) {
    return node ? node->height : 0;
}

int max(int a, int b) {
    return (a > b) ? a : b;
}

int getBalance(struct Node* node) {
    return node ? height(node->left) - height(node->right) : 0;
}

struct Node* createNode(int key) {
    struct Node* node = (struct Node*)malloc(sizeof(struct Node));
    node->key = key;
    node->height = 1;
    node->left = NULL;
    node->right = NULL;
    return node;
}

struct Node* rightRotate(struct Node* y) {
    struct Node* x = y->left;
    struct Node* T2 = x->right;    
    x->right = y;
    y->left = T2;    
    y->height = 1 + max(height(y->left), height(y->right));
    x->height = 1 + max(height(x->left), height(x->right));
    
    return x;
}

struct Node* leftRotate(struct Node* x) {
    struct Node* y = x->right;
    struct Node* T2 = y->left;    
    y->left = x;
    x->right = T2;    
    x->height = 1 + max(height(x->left), height(x->right));
    y->height = 1 + max(height(y->left), height(y->right));
    
    return y;
}

struct Node* insert(struct Node* node, int key) {
    if (node == NULL)
        return createNode(key);
    
    if (key < node->key)
        node->left = insert(node->left, key);
    else if (key > node->key)
        node->right = insert(node->right, key);
    else
        return node;
    
    node->height = 1 + max(height(node->left), height(node->right));

    int balance = getBalance(node);    
    if (balance > 1 && key < node->left->key)
        return rightRotate(node);    
    if (balance < -1 && key > node->right->key)
        return leftRotate(node);    
    if (balance > 1 && key > node->left->key) {
        node->left = leftRotate(node->left);
        return rightRotate(node);
    }    
    if (balance < -1 && key < node->right->key) {
        node->right = rightRotate(node->right);
        return leftRotate(node);
    }    
    return node;
}

void inorder(struct Node* root) {
    if (root != NULL) {
        inorder(root->left);
        printf("%d ", root->key);
        inorder(root->right);
    }
}

int main() {
    struct Node* root = NULL;
    int key;    
    while (scanf("%d", &key) == 1) {
        root = insert(root, key);
    }    
    inorder(root);
    printf("\n");    
    return 0;
}
