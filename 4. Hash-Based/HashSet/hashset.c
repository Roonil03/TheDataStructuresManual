/* Each bucket holds a chain of distinct integers. */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define DEFAULT_CAPACITY 16

typedef struct Node {
    int value;
    struct Node* next;
} Node;

typedef struct HashSet {
    Node** buckets;
    int capacity;
    int size;
} HashSet;

HashSet* create_hashset(int capacity);
int hash_function(int value, int capacity);
bool add(HashSet* set, int value);
bool contains(HashSet* set, int value);
bool remove_element(HashSet* set, int value);
int get_size(HashSet* set);
void display(HashSet* set);
void clear_hashset(HashSet* set);
void destroy(HashSet* set);

HashSet* create_hashset(int capacity) {
    if (capacity <= 0) return NULL;
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

int hash_function(int value, int capacity) {
    int remainder = value % capacity;
    return remainder < 0 ? -remainder : remainder;
}

bool add(HashSet* set, int value) {
    if (!set) return false;

    if (contains(set, value)) {
        return false;
    }

    int index = hash_function(value, set->capacity);

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

int get_size(HashSet* set) {
    return set ? set->size : 0;
}

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

void destroy(HashSet* set) {
    if (!set) return;

    clear_hashset(set);
    free(set->buckets);
    free(set);
}

int main() {

    HashSet* set = create_hashset(DEFAULT_CAPACITY);
    if (!set) {
        fprintf(stderr, "Failed to create HashSet\n");
        return 1;
    }

    add(set, 10);
    add(set, 20);
    add(set, 15);
    add(set, 25);
    add(set, 10);

    printf("HashSet after adding elements:\n");
    display(set);

    printf("\nContains 15: %s\n", contains(set, 15) ? "Yes" : "No");
    printf("Contains 100: %s\n", contains(set, 100) ? "Yes" : "No");

    printf("\nSize: %d\n", get_size(set));

    remove_element(set, 20);

    printf("\nHashSet after removing 20:\n");
    display(set);

    printf("\nSize: %d\n", get_size(set));

    destroy(set);

    return 0;
}
