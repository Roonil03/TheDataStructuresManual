#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define TopLeftFront      0
#define TopRightFront     1
#define BottomRightFront  2
#define BottomLeftFront   3
#define TopLeftBottom     4
#define TopRightBottom    5
#define BottomRightBack   6
#define BottomLeftBack    7

typedef struct Point {
    int x, y, z;
} Point;

typedef struct Octree {
    // If is_leaf==true and point.x>=0: contains a point
    // If is_leaf==true and point.x<0: empty
    // If is_leaf==false: internal node with children
    bool is_leaf;
    Point point; 
    Point min_bound, max_bound;
    struct Octree* children[8];
} Octree;

Octree* octree_create(Point min_b, Point max_b) {
    Octree* tree = malloc(sizeof(Octree));
    tree->is_leaf = true;
    tree->point.x = -1;  // empty marker
    tree->min_bound = min_b;
    tree->max_bound = max_b;
    for(int i=0;i<8;i++) tree->children[i] = NULL;
    return tree;
}

// Determine octant for (x,y,z) within node bounds
int octant_of(Octree* node, int x, int y, int z) {
    int midx = (node->min_bound.x + node->max_bound.x) / 2;
    int midy = (node->min_bound.y + node->max_bound.y) / 2;
    int midz = (node->min_bound.z + node->max_bound.z) / 2;
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
    node->point.x = -1;
    for(int i=0;i<8;i++) {
        // compute bounds for child i
        Point minb = node->min_bound, maxb = node->max_bound;
        int midx = (minb.x + maxb.x)/2;
        int midy = (minb.y + maxb.y)/2;
        int midz = (minb.z + maxb.z)/2;
        if(i & 1) minb.x = midx+1; else maxb.x = midx;
        if(i & 2) minb.y = midy+1; else maxb.y = midy;
        if(i & 4) minb.z = midz+1; else maxb.z = midz;
        node->children[i] = octree_create(minb, maxb);
    }
    // re-insert old point
    int oct = octant_of(node, old.x, old.y, old.z);
    node->children[oct]->is_leaf = true;
    node->children[oct]->point = old;
}

void octree_insert(Octree* node, int x, int y, int z) {
    if(x < node->min_bound.x || x > node->max_bound.x ||
       y < node->min_bound.y || y > node->max_bound.y ||
       z < node->min_bound.z || z > node->max_bound.z) {
        printf("Point is out of bound\n");
        return;
    }
    if(node->is_leaf) {
        if(node->point.x < 0) {
            node->point.x = x;
            node->point.y = y;
            node->point.z = z;
            printf("Point inserted\n");
        } else {
            if(node->point.x==x && node->point.y==y && node->point.z==z) {
                printf("Point already exist in the tree\n");
            } else {
                // collision: subdivide then insert both
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
    if(x < node->min_bound.x || x > node->max_bound.x ||
       y < node->min_bound.y || y > node->max_bound.y ||
       z < node->min_bound.z || z > node->max_bound.z) {
        return false;
    }
    if(node->is_leaf) {
        return (node->point.x==x && node->point.y==y && node->point.z==z);
    } else {
        int oct = octant_of(node,x,y,z);
        return octree_find(node->children[oct], x,y,z);
    }
}

void octree_display(Octree* node, int depth) {
    if(node->is_leaf) {
        if(node->point.x>=0) {
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
            printf("Enter X (0-255): "); scanf("%d",&x);
            printf("Enter Y (0-255): "); scanf("%d",&y);
            printf("Enter Z (0-255): "); scanf("%d",&z);
            octree_insert(root,x,y,z);
        }
        else if(choice==2) {
            int x,y,z;
            printf("Enter X (0-255): "); scanf("%d",&x);
            printf("Enter Y (0-255): "); scanf("%d",&y);
            printf("Enter Z (0-255): "); scanf("%d",&z);
            printf(octree_find(root,x,y,z) ? "Found\n" : "Not Found\n");
        }
        else if(choice==3) {
            printf("Tree contents:\n");
            octree_display(root,0);
        }
        else break;
    }
    return 0;
}
