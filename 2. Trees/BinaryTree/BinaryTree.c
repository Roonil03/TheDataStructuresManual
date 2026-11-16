/* Binary tree insertion fills both children before descending left. */
#include <stdio.h>
#include <stdlib.h>

struct Node {
    int data;
    struct Node* left;
    struct Node* right;
};

struct Node* createNode(int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    if (!newNode) exit(EXIT_FAILURE);
    newNode->data = data;
    newNode->left = newNode->right = NULL;
    return newNode;
}

struct Node* insert(struct Node* root, int data) {
    if (root == NULL) return createNode(data);

    if (root->left == NULL)
        root->left = createNode(data);
    else if (root->right == NULL)
        root->right = createNode(data);
    else {
        root->left = insert(root->left, data);
    }
    return root;
}

void inorder(struct Node* root) {
    if (root != NULL) {
        inorder(root->left);
        printf("%d ", root->data);
        inorder(root->right);
    }
}

void preorder(struct Node* root) {
    if (root != NULL) {
        printf("%d ", root->data);
        preorder(root->left);
        preorder(root->right);
    }
}

void free_tree(struct Node *node) {
    if (node == NULL) return;
    free_tree(node->left);
    free_tree(node->right);
    free(node);
}

int main() {
    struct Node* root = NULL;
    int n, data;

    printf("Enter number of nodes: ");
    if (scanf("%d", &n) != 1 || n < 0) return EXIT_FAILURE;

    printf("Enter values: ");
    for (int i = 0; i < n; i++) {
        if (scanf("%d", &data) != 1) { free_tree(root); return EXIT_FAILURE; }
        root = insert(root, data);
    }

    printf("Inorder: ");
    inorder(root);
    printf("\nPreorder: ");
    preorder(root);
    printf("\n");

    free_tree(root);
    return 0;
}
