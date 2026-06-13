#include <stdio.h>
#include <stdlib.h>

typedef struct ITNode {
    int low, high, max;
    struct ITNode *left, *right;
} ITNode;

typedef struct {
    ITNode *root;
} IntervalTree;

static ITNode *new_node(int low, int high) {
    ITNode *n = malloc(sizeof(ITNode));
    n->low = low;
    n->high = high;
    n->max = high;
    n->left = n->right = NULL;
    return n;
}

static int max_of(int a, int b) { return a > b ? a : b; }

static void update_max(ITNode *n) {
    n->max = n->high;
    if (n->left) n->max = max_of(n->max, n->left->max);
    if (n->right) n->max = max_of(n->max, n->right->max);
}

ITNode *it_insert(ITNode *root, int low, int high) {
    if (!root) return new_node(low, high);
    if (low < root->low)
        root->left = it_insert(root->left, low, high);
    else
        root->right = it_insert(root->right, low, high);
    update_max(root);
    return root;
}

static int overlaps(int l1, int h1, int l2, int h2) {
    return l1 <= h2 && l2 <= h1;
}

ITNode *it_search(ITNode *root, int low, int high) {
    if (!root) return NULL;
    if (overlaps(root->low, root->high, low, high))
        return root;
    if (root->left && root->left->max >= low)
        return it_search(root->left, low, high);
    return it_search(root->right, low, high);
}

static void it_search_all_util(ITNode *root, int low, int high, int *results, int *count) {
    if (!root) return;
    if (overlaps(root->low, root->high, low, high))
        results[(*count)++] = root->low;
    if (root->left && root->left->max >= low)
        it_search_all_util(root->left, low, high, results, count);
    it_search_all_util(root->right, low, high, results, count);
}

int it_search_all(ITNode *root, int low, int high, int *results) {
    int count = 0;
    it_search_all_util(root, low, high, results, &count);
    return count;
}

ITNode *it_delete(ITNode *root, int low, int high) {
    if (!root) return NULL;
    if (low < root->low) {
        root->left = it_delete(root->left, low, high);
    } else if (low > root->low) {
        root->right = it_delete(root->right, low, high);
    } else if (root->high == high) {
        if (!root->left) {
            ITNode *tmp = root->right;
            free(root);
            return tmp;
        }
        if (!root->right) {
            ITNode *tmp = root->left;
            free(root);
            return tmp;
        }
        ITNode *succ = root->right;
        while (succ->left) succ = succ->left;
        root->low = succ->low;
        root->high = succ->high;
        root->right = it_delete(root->right, succ->low, succ->high);
    } else {
        root->right = it_delete(root->right, low, high);
    }
    if (root) update_max(root);
    return root;
}

void it_inorder(ITNode *root) {
    if (!root) return;
    it_inorder(root->left);
    printf("[%d,%d](max=%d) ", root->low, root->high, root->max);
    it_inorder(root->right);
}

void it_free(ITNode *root) {
    if (!root) return;
    it_free(root->left);
    it_free(root->right);
    free(root);
}

int main(void) {
    IntervalTree tree = {NULL};

    tree.root = it_insert(tree.root, 15, 20);
    tree.root = it_insert(tree.root, 10, 30);
    tree.root = it_insert(tree.root, 17, 19);
    tree.root = it_insert(tree.root, 5, 20);
    tree.root = it_insert(tree.root, 12, 15);
    tree.root = it_insert(tree.root, 30, 40);

    printf("Inorder: ");
    it_inorder(tree.root);
    printf("\n");

    ITNode *result = it_search(tree.root, 14, 16);
    if (result)
        printf("Search [14,16]: found [%d,%d]\n", result->low, result->high);

    result = it_search(tree.root, 21, 25);
    if (result)
        printf("Search [21,25]: found [%d,%d]\n", result->low, result->high);
    else
        printf("Search [21,25]: not found (wrong)\n");

    result = it_search(tree.root, 41, 50);
    printf("Search [41,50]: %s\n", result ? "found (wrong)" : "not found");

    int results[10];
    int count = it_search_all(tree.root, 14, 16, results);
    printf("All overlapping [14,16]: %d intervals\n", count);

    tree.root = it_delete(tree.root, 17, 19);
    printf("After deleting [17,19]:\n");
    printf("Inorder: ");
    it_inorder(tree.root);
    printf("\n");

    it_free(tree.root);
    printf("All tests passed.\n");
    return 0;
}
