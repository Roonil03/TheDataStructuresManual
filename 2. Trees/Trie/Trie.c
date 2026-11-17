#include "../../common/input.h"
/* Lowercase-word trie with terminal markers and exact-word lookup. */
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
    if (!node) exit(EXIT_FAILURE);
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
    for (int i = 0; i < length; i++)
        if (word[i] < 'a' || word[i] > 'z') return;

    for (int i = 0; i < length; i++) {
        int index = (unsigned char)word[i] - 'a';
        if (index < 0 || index >= ALPHABET_SIZE) return;

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
        int index = (unsigned char)word[i] - 'a';
        if (index < 0 || index >= ALPHABET_SIZE) return 0;

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

static int readWord(char *word, size_t capacity) {
    if (!readToken(word, capacity)) return 0;
    for (size_t i = 0; word[i] != '\0'; i++) {
        if (word[i] < 'a' || word[i] > 'z') {
            fprintf(stderr, "Invalid word input.\n");
            return 0;
        }
    }
    return 1;
}

int main() {
    TrieNode* root = create_node();
    if (!root) {
        return 1;
    }

    int word_count;
    char buffer[256];

    if (!readInteger(&word_count) || word_count < 0) { free_trie(root); return EXIT_FAILURE; }

    for (int i = 0; i < word_count; i++) {
        if (!readWord(buffer, sizeof buffer)) { free_trie(root); return EXIT_FAILURE; }
        insert(root, buffer);
    }

    int search_count;
    if (!readInteger(&search_count) || search_count < 0) { free_trie(root); return EXIT_FAILURE; }

    for (int i = 0; i < search_count; i++) {
        if (!readWord(buffer, sizeof buffer)) { free_trie(root); return EXIT_FAILURE; }

        if (search(root, buffer)) {
            printf("Found: %s\n", buffer);
        } else {
            printf("Not found: %s\n", buffer);
        }
    }

    free_trie(root);
    return 0;
}
