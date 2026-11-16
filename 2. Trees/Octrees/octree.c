/* Bounded octree insertion, lookup, and recursive display. */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define TopLeftFront      0
#define TopRightFront     1
#define BottomRightFront  3
#define BottomLeftFront   2
#define TopLeftBottom     4
#define TopRightBottom    5
#define BottomRightBack   7
#define BottomLeftBack    6

typedef struct Point {
    int x, y, z;
} Point;

typedef struct Octree {
    bool is_leaf;
    bool occupied;
    Point point;
    Point min_bound, max_bound;
    struct Octree* children[8];
} Octree;

Octree* octree_create(Point min_b, Point max_b) {
    if (min_b.x > max_b.x || min_b.y > max_b.y || min_b.z > max_b.z) return NULL;
    Octree* tree = malloc(sizeof(Octree));
    if (!tree) exit(EXIT_FAILURE);
    tree->is_leaf = true;
    tree->occupied = false;
    tree->point = (Point){0, 0, 0};
    tree->min_bound = min_b;
    tree->max_bound = max_b;
    for(int i=0;i<8;i++) tree->children[i] = NULL;
    return tree;
}

int octant_of(Octree* node, int x, int y, int z) {
    int midx = node->min_bound.x + ((long long)node->max_bound.x - node->min_bound.x) / 2;
    int midy = node->min_bound.y + ((long long)node->max_bound.y - node->min_bound.y) / 2;
    int midz = node->min_bound.z + ((long long)node->max_bound.z - node->min_bound.z) / 2;
    if(x <= midx) {
        if(y <= midy) {
            return (z <= midz ? TopLeftFront : TopLeftBottom);
        } else {
            return (z <= midz ? BottomLeftFront : BottomLeftBack);
        }
    } else {
        if(y <= midy) {
            return (z <= midz ? TopRightFront : TopRightBottom);
        } else {
            return (z <= midz ? BottomRightFront : BottomRightBack);
        }
    }
}

void octree_subdivide(Octree* node) {
    node->is_leaf = false;
    Point old = node->point;
    node->occupied = false;
    for(int i=0;i<8;i++) {

        Point minb = node->min_bound, maxb = node->max_bound;
        if (((i & 1) && minb.x == maxb.x) ||
            ((i & 2) && minb.y == maxb.y) ||
            ((i & 4) && minb.z == maxb.z)) {
            node->children[i] = NULL;
            continue;
        }
        int midx = minb.x + ((long long)maxb.x - minb.x) / 2;
        int midy = minb.y + ((long long)maxb.y - minb.y) / 2;
        int midz = minb.z + ((long long)maxb.z - minb.z) / 2;
        if(i & 1) minb.x = midx+1; else maxb.x = midx;
        if(i & 2) minb.y = midy+1; else maxb.y = midy;
        if(i & 4) minb.z = midz+1; else maxb.z = midz;
        node->children[i] = octree_create(minb, maxb);
    }

    int oct = octant_of(node, old.x, old.y, old.z);
    node->children[oct]->is_leaf = true;
    node->children[oct]->point = old;
    node->children[oct]->occupied = true;
}

void octree_insert(Octree* node, int x, int y, int z) {
    if (!node) return;
    if(x < node->min_bound.x || x > node->max_bound.x ||
       y < node->min_bound.y || y > node->max_bound.y ||
       z < node->min_bound.z || z > node->max_bound.z) {
        printf("Point is out of bound\n");
        return;
    }
    if(node->is_leaf) {
        if(!node->occupied) {
            node->occupied = true;
            node->point.x = x;
            node->point.y = y;
            node->point.z = z;
            printf("Point inserted\n");
        } else {
            if(node->point.x==x && node->point.y==y && node->point.z==z) {
                printf("Point already exist in the tree\n");
            } else {

                octree_subdivide(node);
                octree_insert(node, x,y,z);
            }
        }
    } else {
        int oct = octant_of(node,x,y,z);
        octree_insert(node->children[oct], x,y,z);
    }
}

bool octree_find(Octree* node, int x, int y, int z) {
    if (!node) return false;
    if(x < node->min_bound.x || x > node->max_bound.x ||
       y < node->min_bound.y || y > node->max_bound.y ||
       z < node->min_bound.z || z > node->max_bound.z) {
        return false;
    }
    if(node->is_leaf) {
        return (node->occupied && node->point.x==x && node->point.y==y && node->point.z==z);
    } else {
        int oct = octant_of(node,x,y,z);
        return octree_find(node->children[oct], x,y,z);
    }
}

void octree_display(Octree* node, int depth) {
    if (!node) return;
    if(node->is_leaf) {
        if(node->occupied) {
            for(int i=0;i<depth;i++) printf("  ");
            printf("(%d,%d,%d)\n",
                   node->point.x,
                   node->point.y,
                   node->point.z);
        }
    } else {
        for(int i=0;i<depth;i++) printf("  ");
        printf("internal\n");
        for(int i=0;i<8;i++)
            octree_display(node->children[i], depth+1);
    }
}

void octree_free(Octree *node) {
    if (!node) return;
    for (int i = 0; i < 8; i++) octree_free(node->children[i]);
    free(node);
}

int main() {
    Point minb = {0,0,0}, maxb = {255,255,255};
    Octree* root = octree_create(minb, maxb);
    while(true) {
        printf("\nOctree Operations:\n"
               "1. Insert point\n"
               "2. Search point\n"
               "3. Display tree\n"
               "4. Exit\n"
               "Enter choice: ");
        int choice; if(scanf("%d",&choice)!=1) break;
        if(choice==1) {
            int x,y,z;
            printf("Enter X (0-255): "); if (scanf("%d",&x) != 1) { octree_free(root); return EXIT_FAILURE; }
            printf("Enter Y (0-255): "); if (scanf("%d",&y) != 1) { octree_free(root); return EXIT_FAILURE; }
            printf("Enter Z (0-255): "); if (scanf("%d",&z) != 1) { octree_free(root); return EXIT_FAILURE; }
            octree_insert(root,x,y,z);
        }
        else if(choice==2) {
            int x,y,z;
            printf("Enter X (0-255): "); if (scanf("%d",&x) != 1) { octree_free(root); return EXIT_FAILURE; }
            printf("Enter Y (0-255): "); if (scanf("%d",&y) != 1) { octree_free(root); return EXIT_FAILURE; }
            printf("Enter Z (0-255): "); if (scanf("%d",&z) != 1) { octree_free(root); return EXIT_FAILURE; }
            printf(octree_find(root,x,y,z) ? "Found\n" : "Not Found\n");
        }
        else if(choice==3) {
            printf("Tree contents:\n");
            octree_display(root,0);
        }
        else break;
    }
    octree_free(root);
    return 0;
}
