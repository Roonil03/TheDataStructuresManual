#include "../../common/input.h"
/* R-tree insertion propagates child splits and bounding rectangles upward. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <float.h>
#include <stdbool.h>
#include <math.h>

#define M 4
#define m 2

typedef struct {
    double xmin, ymin, xmax, ymax;
} Rectangle;

typedef struct RTreeNode {
    bool is_leaf;
    int count;
    Rectangle mbr[M];
    union {
        struct RTreeNode *child[M];
        int data_id[M];
    };
} RTreeNode;

typedef struct {
    RTreeNode *root;
    int total_nodes;
} RTree;

RTree* create_rtree();
RTreeNode* create_node(bool is_leaf);
void insert_rect(RTree *tree, Rectangle rect, int data_id);
void search_range(RTreeNode *node, Rectangle query, int depth);
void display_tree(RTreeNode *node, int depth);
double calc_area(Rectangle r);
double calc_enlargement(Rectangle r1, Rectangle r2);
Rectangle union_rect(Rectangle r1, Rectangle r2);
void free_rtree(RTreeNode *node);

RTree* create_rtree() {
    RTree *tree = (RTree*)malloc(sizeof(RTree));
    if (!tree) exit(EXIT_FAILURE);
    tree->root = create_node(true);
    tree->total_nodes = 1;
    return tree;
}

RTreeNode* create_node(bool is_leaf) {
    RTreeNode *node = (RTreeNode*)calloc(1, sizeof(RTreeNode));
    if (!node) exit(EXIT_FAILURE);
    node->is_leaf = is_leaf;
    node->count = 0;
    return node;
}

double calc_area(Rectangle r) {
    return (r.xmax - r.xmin) * (r.ymax - r.ymin);
}

double calc_enlargement(Rectangle r1, Rectangle r2) {
    Rectangle enlarged = union_rect(r1, r2);
    return calc_area(enlarged) - calc_area(r1);
}

Rectangle union_rect(Rectangle r1, Rectangle r2) {
    Rectangle result;
    result.xmin = (r1.xmin < r2.xmin) ? r1.xmin : r2.xmin;
    result.ymin = (r1.ymin < r2.ymin) ? r1.ymin : r2.ymin;
    result.xmax = (r1.xmax > r2.xmax) ? r1.xmax : r2.xmax;
    result.ymax = (r1.ymax > r2.ymax) ? r1.ymax : r2.ymax;
    return result;
}

bool rectangles_overlap(Rectangle r1, Rectangle r2) {
    return !(r1.xmax < r2.xmin || r2.xmax < r1.xmin ||
             r1.ymax < r2.ymin || r2.ymax < r1.ymin);
}

RTreeNode* choose_leaf(RTreeNode *node, Rectangle rect) {
    if (node->is_leaf) {
        return node;
    }

    int best_idx = 0;
    double min_enlargement = DBL_MAX;
    double min_area = DBL_MAX;

    for (int i = 0; i < node->count; i++) {
        double enlargement = calc_enlargement(node->mbr[i], rect);
        double area = calc_area(node->mbr[i]);

        if (enlargement < min_enlargement ||
            (enlargement == min_enlargement && area < min_area)) {
            min_enlargement = enlargement;
            min_area = area;
            best_idx = i;
        }
    }

    return choose_leaf(node->child[best_idx], rect);
}

void quadratic_split(RTreeNode *node, RTreeNode **new_node,
                     Rectangle new_rect, int new_data, RTreeNode *new_child) {
    *new_node = create_node(node->is_leaf);

    Rectangle all_rects[M + 1];
    int all_data[M + 1];
    RTreeNode *all_children[M + 1];

    for (int i = 0; i < M; i++) {
        all_rects[i] = node->mbr[i];
        if (node->is_leaf) {
            all_data[i] = node->data_id[i];
        } else {
            all_children[i] = node->child[i];
        }
    }
    all_rects[M] = new_rect;
    if (node->is_leaf) {
        all_data[M] = new_data;
    } else {
        all_children[M] = new_child;
    }

    int seed1 = 0, seed2 = 1;
    double max_waste = -DBL_MAX;

    for (int i = 0; i < M + 1; i++) {
        for (int j = i + 1; j < M + 1; j++) {
            Rectangle combined = union_rect(all_rects[i], all_rects[j]);
            double waste = calc_area(combined) - calc_area(all_rects[i])
                          - calc_area(all_rects[j]);
            if (waste > max_waste) {
                max_waste = waste;
                seed1 = i;
                seed2 = j;
            }
        }
    }

    node->count = 0;
    (*new_node)->count = 0;

    node->mbr[0] = all_rects[seed1];
    if (node->is_leaf) {
        node->data_id[0] = all_data[seed1];
    } else {
        node->child[0] = all_children[seed1];
    }
    node->count = 1;

    (*new_node)->mbr[0] = all_rects[seed2];
    if ((*new_node)->is_leaf) {
        (*new_node)->data_id[0] = all_data[seed2];
    } else {
        (*new_node)->child[0] = all_children[seed2];
    }
    (*new_node)->count = 1;

    bool assigned[M + 1] = {false};
    assigned[seed1] = assigned[seed2] = true;

    for (int i = 0; i < M + 1; i++) {
        if (assigned[i]) continue;

        Rectangle union1 = node->mbr[0];
        Rectangle union2 = (*new_node)->mbr[0];

        for (int j = 1; j < node->count; j++) {
            union1 = union_rect(union1, node->mbr[j]);
        }
        for (int j = 1; j < (*new_node)->count; j++) {
            union2 = union_rect(union2, (*new_node)->mbr[j]);
        }

        double enl1 = calc_enlargement(union1, all_rects[i]);
        double enl2 = calc_enlargement(union2, all_rects[i]);

        int remaining = 0;
        for (int j = i; j < M + 1; j++) if (!assigned[j]) remaining++;
        if (node->count + remaining == m ||
            ((*new_node)->count + remaining != m &&
             (enl1 < enl2 || (enl1 == enl2 &&
              (calc_area(union1) < calc_area(union2) ||
               (calc_area(union1) == calc_area(union2) &&
                node->count < (*new_node)->count)))))) {
            node->mbr[node->count] = all_rects[i];
            if (node->is_leaf) {
                node->data_id[node->count] = all_data[i];
            } else {
                node->child[node->count] = all_children[i];
            }
            node->count++;
        } else {
            (*new_node)->mbr[(*new_node)->count] = all_rects[i];
            if ((*new_node)->is_leaf) {
                (*new_node)->data_id[(*new_node)->count] = all_data[i];
            } else {
                (*new_node)->child[(*new_node)->count] = all_children[i];
            }
            (*new_node)->count++;
        }
    }
}

Rectangle node_bounds(RTreeNode *node) {
    Rectangle bounds = node->mbr[0];
    for (int i = 1; i < node->count; i++) bounds = union_rect(bounds, node->mbr[i]);
    return bounds;
}

void insert_rect_recursive(RTree *tree, RTreeNode *node, Rectangle rect,
                           int data_id, RTreeNode **split_node,
                           Rectangle *split_mbr) {
    RTreeNode *child_split = NULL;
    Rectangle entry = rect;
    if (!node->is_leaf) {
        int best = 0;
        for (int i = 1; i < node->count; i++) {
            double candidate = calc_enlargement(node->mbr[i], rect);
            double current = calc_enlargement(node->mbr[best], rect);
            if (candidate < current ||
                (candidate == current && calc_area(node->mbr[i]) < calc_area(node->mbr[best])))
                best = i;
        }
        insert_rect_recursive(tree, node->child[best], rect, data_id,
                              &child_split, &entry);
        node->mbr[best] = node_bounds(node->child[best]);
        if (!child_split) { *split_node = NULL; return; }
    }
    if (node->count < M) {
        node->mbr[node->count] = entry;
        if (node->is_leaf) node->data_id[node->count] = data_id;
        else node->child[node->count] = child_split;
        node->count++;
        *split_node = NULL;
    } else {
        quadratic_split(node, split_node, entry, data_id, child_split);
        *split_mbr = node_bounds(*split_node);
        tree->total_nodes++;
    }
}

bool valid_rectangle(Rectangle rect) {
    return isfinite(rect.xmin) && isfinite(rect.ymin) &&
           isfinite(rect.xmax) && isfinite(rect.ymax) &&
           rect.xmin <= rect.xmax && rect.ymin <= rect.ymax;
}

void insert_rect(RTree *tree, Rectangle rect, int data_id) {
    if (!valid_rectangle(rect)) return;
    RTreeNode *split = NULL;
    Rectangle split_mbr;
    insert_rect_recursive(tree, tree->root, rect, data_id, &split, &split_mbr);
    if (split) {
        RTreeNode *new_root = create_node(false);
        new_root->count = 2;
        new_root->child[0] = tree->root;
        new_root->mbr[0] = node_bounds(tree->root);
        new_root->child[1] = split;
        new_root->mbr[1] = split_mbr;
        tree->root = new_root;
        tree->total_nodes++;
    }
}

void search_range(RTreeNode *node, Rectangle query, int depth) {
    if (node == NULL) return;

    if (node->is_leaf) {
        for (int i = 0; i < node->count; i++) {
            if (rectangles_overlap(node->mbr[i], query)) {
                printf("  Found: ID=%d, Rect[%.1f,%.1f,%.1f,%.1f]\n",
                       node->data_id[i],
                       node->mbr[i].xmin, node->mbr[i].ymin,
                       node->mbr[i].xmax, node->mbr[i].ymax);
            }
        }
    } else {
        for (int i = 0; i < node->count; i++) {
            if (rectangles_overlap(node->mbr[i], query)) {
                search_range(node->child[i], query, depth + 1);
            }
        }
    }
}

void display_tree(RTreeNode *node, int depth) {
    if (node == NULL) return;

    for (int i = 0; i < depth; i++) printf("  ");

    if (node->is_leaf) {
        printf("LEAF [%d entries]:\n", node->count);
        for (int i = 0; i < node->count; i++) {
            for (int j = 0; j < depth + 1; j++) printf("  ");
            printf("ID=%d: [%.1f,%.1f,%.1f,%.1f]\n",
                   node->data_id[i],
                   node->mbr[i].xmin, node->mbr[i].ymin,
                   node->mbr[i].xmax, node->mbr[i].ymax);
        }
    } else {
        printf("INTERNAL [%d entries]:\n", node->count);
        for (int i = 0; i < node->count; i++) {
            for (int j = 0; j < depth + 1; j++) printf("  ");
            printf("MBR[%.1f,%.1f,%.1f,%.1f]:\n",
                   node->mbr[i].xmin, node->mbr[i].ymin,
                   node->mbr[i].xmax, node->mbr[i].ymax);
            display_tree(node->child[i], depth + 2);
        }
    }
}

void free_rtree(RTreeNode *node) {
    if (node == NULL) return;

    if (!node->is_leaf) {
        for (int i = 0; i < node->count; i++) {
            free_rtree(node->child[i]);
        }
    }
    free(node);
}

int main() {
    RTree *tree = create_rtree();
    int choice, id;
    Rectangle rect;

    printf("R-Tree Implementation\n\n");

    while (1) {
        printf("\n--- Menu ---\n");
        printf("1. Insert Rectangle\n");
        printf("2. Range Search\n");
        printf("3. Display Tree\n");
        printf("4. Exit\n");
        printf("Enter choice: ");

        if (!readInteger(&choice)) break;

        switch (choice) {
            case 1:
                printf("Enter rectangle (xmin ymin xmax ymax): ");
                if (!readDouble(&rect.xmin) || !readDouble(&rect.ymin) ||
                    !readDouble(&rect.xmax) || !readDouble(&rect.ymax)) goto done;
                printf("Enter data ID: ");
                if (!readInteger(&id)) goto done;
                if (!valid_rectangle(rect)) { printf("Invalid rectangle!\n"); break; }
                insert_rect(tree, rect, id);
                printf("Rectangle inserted successfully!\n");
                break;

            case 2:
                printf("Enter query rectangle (xmin ymin xmax ymax): ");
                if (!readDouble(&rect.xmin) || !readDouble(&rect.ymin) ||
                    !readDouble(&rect.xmax) || !readDouble(&rect.ymax)) goto done;
                if (!valid_rectangle(rect)) { printf("Invalid rectangle!\n"); break; }
                printf("\nSearch results:\n");
                search_range(tree->root, rect, 0);
                break;

            case 3:
                printf("\nR-Tree structure:\n");
                display_tree(tree->root, 0);
                break;

            case 4:
                free_rtree(tree->root);
                free(tree);
                printf("Goodbye!\n");
                return 0;

            default:
                printf("Invalid choice!\n");
        }
    }
done:
    free_rtree(tree->root);
    free(tree);
    return 0;
}
