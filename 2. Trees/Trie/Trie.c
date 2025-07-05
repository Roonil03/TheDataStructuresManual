#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ALPHABET_SIZE 26

typedef struct TrieNode {
    int is_end_of_word;
    struct TrieNode* children[ALPHABET_SIZE];
} TrieNode;

TrieNode* create_node() {
    TrieNode* node = (TrieNode*)malloc(sizeof(TrieNode));
    if (node) {
        node->is_end_of_word = 0;
        for (int i = 0; i < ALPHABET_SIZE; i++) {
            node->children[i] = NULL;
        }
    }
    return node;
}

void insert(TrieNode* root, char* word) {
    TrieNode* current = root;
    int length = strlen(word);
    
    for (int i = 0; i < length; i++) {
        int index = word[i] - 'a';
        
        if (!current->children[index]) {
            current->children[index] = create_node();
        }
        
        current = current->children[index];
    }
    
    current->is_end_of_word = 1;
}

int search(TrieNode* root, char* word) {
    TrieNode* current = root;
    int length = strlen(word);
    
    for (int i = 0; i < length; i++) {
        int index = word[i] - 'a';
        
        if (!current->children[index]) {
            return 0;
        }
        
        current = current->children[index];
    }
    
    return current->is_end_of_word;
}

void free_trie(TrieNode* root) {
    if (!root) return;
    
    for (int i = 0; i < ALPHABET_SIZE; i++) {
        if (root->children[i]) {
            free_trie(root->children[i]);
        }
    }
    
    free(root);
}

int main() {
    TrieNode* root = create_node();
    if (!root) {
        return 1;
    }
    
    int word_count;
    char buffer[256];
    
    scanf("%d", &word_count);
    
    for (int i = 0; i < word_count; i++) {
        scanf("%s", buffer);
        insert(root, buffer);
    }
    
    int search_count;
    scanf("%d", &search_count);
    
    for (int i = 0; i < search_count; i++) {
        scanf("%s", buffer);
        
        if (search(root, buffer)) {
            printf("Found: %s\n", buffer);
        } else {
            printf("Not found: %s\n", buffer);
        }
    }
    
    free_trie(root);
    return 0;
}
