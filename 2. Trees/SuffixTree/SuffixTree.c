#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_CHAR 256
#define MAX_N 1000

typedef struct SuffixNode {
    int start;
    int end;
    struct SuffixNode* children[MAX_CHAR];
    struct SuffixNode* suffix_link;
    int leaf_end;
} SuffixNode;

char text[MAX_N];
int text_length;
SuffixNode* root;

SuffixNode* create_node(int start, int end) {
    SuffixNode* node = malloc(sizeof(SuffixNode));
    node->start = start;
    node->end = end;
    node->suffix_link = NULL;
    node->leaf_end = 0;
    
    for (int i = 0; i < MAX_CHAR; i++) {
        node->children[i] = NULL;
    }
    
    return node;
}

int edge_length(SuffixNode* node) {
    if (node->leaf_end) {
        return text_length - node->start;
    }
    return node->end - node->start + 1;
}

void build_suffix_tree() {
    root = create_node(0, -1);
    
    for (int i = 0; i < text_length; i++) {
        SuffixNode* current = root;
        
        for (int j = i; j < text_length; j++) {
            unsigned char c = text[j];
            
            if (current->children[c] == NULL) {
                SuffixNode* leaf = create_node(j, text_length - 1);
                leaf->leaf_end = 1;
                current->children[c] = leaf;
                break;
            } else {
                SuffixNode* next = current->children[c];
                int edge_len = edge_length(next);
                int k = 0;
                
                while (k < edge_len && j + k < text_length && 
                       text[next->start + k] == text[j + k]) {
                    k++;
                }
                
                if (k == edge_len) {
                    current = next;
                    j += k - 1;
                    continue;
                }
                
                if (k < edge_len) {
                    SuffixNode* split = create_node(next->start, next->start + k - 1);
                    current->children[c] = split;
                    
                    unsigned char next_char = text[next->start + k];
                    split->children[next_char] = next;
                    next->start += k;
                    
                    if (j + k < text_length) {
                        unsigned char new_char = text[j + k];
                        SuffixNode* new_leaf = create_node(j + k, text_length - 1);
                        new_leaf->leaf_end = 1;
                        split->children[new_char] = new_leaf;
                    }
                    break;
                }
            }
        }
    }
}

int search_pattern(char* pattern) {
    int pattern_len = strlen(pattern);
    if (pattern_len == 0) return 0;
    
    SuffixNode* current = root;
    int i = 0;
    
    while (i < pattern_len) {
        unsigned char c = pattern[i];
        
        if (current->children[c] == NULL) {
            return 0;
        }
        
        SuffixNode* next = current->children[c];
        int edge_len = edge_length(next);
        int j = 0;
        
        while (j < edge_len && i < pattern_len) {
            if (text[next->start + j] != pattern[i]) {
                return 0;
            }
            i++;
            j++;
        }
        
        if (i >= pattern_len) {
            return 1;
        }
        
        current = next;
    }
    
    return 1;
}

void free_tree(SuffixNode* node) {
    if (node == NULL) return;
    
    for (int i = 0; i < MAX_CHAR; i++) {
        if (node->children[i] != NULL) {
            free_tree(node->children[i]);
        }
    }
    
    free(node);
}

int main() {
    char pattern[MAX_N];
    
    scanf("%s", text);
    scanf("%s", pattern);
    
    text_length = strlen(text);
    
    build_suffix_tree();
    
    if (search_pattern(pattern)) {
        printf("Found\n");
    } else {
        printf("Not found\n");
    }
    
    free_tree(root);
    return 0;
}
