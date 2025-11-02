/*
 * ============================================================================
 * HashSet Implementation in C
 * ============================================================================
 * Description: This program implements a HashSet data structure that stores
 *              unique integer values using a hash table with separate chaining.
 *
 * Operations:
 *   - create_hashset: Initialize a new hash set
 *   - add: Add an element to the hash set
 *   - contains: Check if an element exists in the hash set
 *   - remove_element: Remove an element from the hash set
 *   - get_size: Get the number of elements in the hash set
 *   - display: Display all elements in the hash set
 *   - clear_hashset: Remove all elements from the hash set
 *   - destroy: Free all allocated memory
 *
 * Compilation: gcc -o hashset_c hashset.c
 * Execution: ./hashset_c
 * ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define DEFAULT_CAPACITY 16

/* Node structure for separate chaining */
typedef struct Node {
    int value;
    struct Node* next;
} Node;

/* HashSet structure */
typedef struct HashSet {
    Node** buckets;
    int capacity;
    int size;
} HashSet;

/* Function prototypes */
HashSet* create_hashset(int capacity);
int hash_function(int value, int capacity);
bool add(HashSet* set, int value);
bool contains(HashSet* set, int value);
bool remove_element(HashSet* set, int value);
int get_size(HashSet* set);
void display(HashSet* set);
void clear_hashset(HashSet* set);
void destroy(HashSet* set);

/*
 * create_hashset: Create and initialize a new HashSet
 * Input: capacity (number of buckets)
 * Output: Pointer to HashSet structure, or NULL on failure
 */
HashSet* create_hashset(int capacity) {
    HashSet* set = (HashSet*)malloc(sizeof(HashSet));
    if (!set) {
        return NULL;
    }
    
    set->buckets = (Node**)calloc(capacity, sizeof(Node*));
    if (!set->buckets) {
        free(set);
        return NULL;
    }
    
    set->capacity = capacity;
    set->size = 0;
    
    return set;
}

/*
 * hash_function: Calculate hash value for a given key
 * Input: value to hash, capacity
 * Output: hash value (bucket index)
 */
int hash_function(int value, int capacity) {
    return abs(value) % capacity;
}

/*
 * add: Add an element to the HashSet
 * Input: HashSet pointer, value to add
 * Output: true if added, false if already exists or error
 */
bool add(HashSet* set, int value) {
    if (!set) return false;
    
    /* Check if value already exists */
    if (contains(set, value)) {
        return false;
    }
    
    /* Calculate hash */
    int index = hash_function(value, set->capacity);
    
    /* Allocate new node */
    Node* new_node = (Node*)malloc(sizeof(Node));
    if (!new_node) {
        return false;
    }
    
    new_node->value = value;
    new_node->next = set->buckets[index];
    set->buckets[index] = new_node;
    
    set->size++;
    return true;
}

/*
 * contains: Check if an element exists in the HashSet
 * Input: HashSet pointer, value to check
 * Output: true if exists, false if not
 */
bool contains(HashSet* set, int value) {
    if (!set) return false;
    
    int index = hash_function(value, set->capacity);
    Node* current = set->buckets[index];
    
    while (current) {
        if (current->value == value) {
            return true;
        }
        current = current->next;
    }
    
    return false;
}

/*
 * remove_element: Remove an element from the HashSet
 * Input: HashSet pointer, value to remove
 * Output: true if removed, false if not found
 */
bool remove_element(HashSet* set, int value) {
    if (!set) return false;
    
    int index = hash_function(value, set->capacity);
    Node* current = set->buckets[index];
    Node* prev = NULL;
    
    while (current) {
        if (current->value == value) {
            if (prev) {
                prev->next = current->next;
            } else {
                set->buckets[index] = current->next;
            }
            free(current);
            set->size--;
            return true;
        }
        prev = current;
        current = current->next;
    }
    
    return false;
}

/*
 * get_size: Get the number of elements in the HashSet
 * Input: HashSet pointer
 * Output: size
 */
int get_size(HashSet* set) {
    return set ? set->size : 0;
}

/*
 * display: Display all elements in the HashSet
 * Input: HashSet pointer
 */
void display(HashSet* set) {
    if (!set) return;
    
    if (set->size == 0) {
        printf("HashSet is empty\n");
        return;
    }
    
    for (int i = 0; i < set->capacity; i++) {
        Node* current = set->buckets[i];
        if (current) {
            printf("%d: ", i);
            while (current) {
                printf("%d ", current->value);
                current = current->next;
            }
            printf("\n");
        }
    }
}

/*
 * clear_hashset: Remove all elements from the HashSet
 * Input: HashSet pointer
 */
void clear_hashset(HashSet* set) {
    if (!set) return;
    
    for (int i = 0; i < set->capacity; i++) {
        Node* current = set->buckets[i];
        while (current) {
            Node* temp = current;
            current = current->next;
            free(temp);
        }
        set->buckets[i] = NULL;
    }
    
    set->size = 0;
}

/*
 * destroy: Free all memory used by the HashSet
 * Input: HashSet pointer
 */
void destroy(HashSet* set) {
    if (!set) return;
    
    clear_hashset(set);
    free(set->buckets);
    free(set);
}

/*
 * Main function - Test the HashSet implementation
 */
int main() {
    /* Create HashSet */
    HashSet* set = create_hashset(DEFAULT_CAPACITY);
    if (!set) {
        fprintf(stderr, "Failed to create HashSet\n");
        return 1;
    }
    
    /* Add elements */
    add(set, 10);
    add(set, 20);
    add(set, 15);
    add(set, 25);
    add(set, 10);  /* Duplicate, should not be added */
    
    /* Display HashSet */
    printf("HashSet after adding elements:\n");
    display(set);
    
    /* Check if elements exist */
    printf("\nContains 15: %s\n", contains(set, 15) ? "Yes" : "No");
    printf("Contains 100: %s\n", contains(set, 100) ? "Yes" : "No");
    
    /* Print size */
    printf("\nSize: %d\n", get_size(set));
    
    /* Remove element */
    remove_element(set, 20);
    
    /* Display after removal */
    printf("\nHashSet after removing 20:\n");
    display(set);
    
    printf("\nSize: %d\n", get_size(set));
    
    /* Clean up */
    destroy(set);
    
    return 0;
}
