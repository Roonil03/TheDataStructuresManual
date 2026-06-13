#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Entry {
    char *key;
    int value;
    struct Entry *next;
} Entry;

typedef struct {
    int capacity;
    int size;
    Entry **buckets;
} HashMap;

static unsigned int hash(const char *key, int cap) {
    unsigned int h = 5381;
    while (*key)
        h = ((h << 5) + h) + (unsigned char)*key++;
    return h % cap;
}

HashMap *hashmap_create(int capacity) {
    HashMap *m = malloc(sizeof(HashMap));
    m->capacity = capacity;
    m->size = 0;
    m->buckets = calloc(capacity, sizeof(Entry *));
    return m;
}

void hashmap_put(HashMap *m, const char *key, int value) {
    unsigned int idx = hash(key, m->capacity);
    for (Entry *e = m->buckets[idx]; e; e = e->next) {
        if (strcmp(e->key, key) == 0) {
            e->value = value;
            return;
        }
    }
    Entry *e = malloc(sizeof(Entry));
    e->key = strdup(key);
    e->value = value;
    e->next = m->buckets[idx];
    m->buckets[idx] = e;
    m->size++;
}

int hashmap_get(HashMap *m, const char *key, int *out) {
    unsigned int idx = hash(key, m->capacity);
    for (Entry *e = m->buckets[idx]; e; e = e->next) {
        if (strcmp(e->key, key) == 0) {
            *out = e->value;
            return 1;
        }
    }
    return 0;
}

int hashmap_contains(HashMap *m, const char *key) {
    unsigned int idx = hash(key, m->capacity);
    for (Entry *e = m->buckets[idx]; e; e = e->next)
        if (strcmp(e->key, key) == 0) return 1;
    return 0;
}

int hashmap_remove(HashMap *m, const char *key) {
    unsigned int idx = hash(key, m->capacity);
    Entry **curr = &m->buckets[idx];
    while (*curr) {
        if (strcmp((*curr)->key, key) == 0) {
            Entry *tmp = *curr;
            *curr = (*curr)->next;
            free(tmp->key);
            free(tmp);
            m->size--;
            return 1;
        }
        curr = &(*curr)->next;
    }
    return 0;
}

void hashmap_print(HashMap *m) {
    printf("HashMap (size=%d, capacity=%d):\n", m->size, m->capacity);
    for (int i = 0; i < m->capacity; i++) {
        if (!m->buckets[i]) continue;
        printf("  [%d]:", i);
        for (Entry *e = m->buckets[i]; e; e = e->next)
            printf(" (%s=%d)", e->key, e->value);
        printf("\n");
    }
}

void hashmap_free(HashMap *m) {
    for (int i = 0; i < m->capacity; i++) {
        Entry *e = m->buckets[i];
        while (e) {
            Entry *tmp = e;
            e = e->next;
            free(tmp->key);
            free(tmp);
        }
    }
    free(m->buckets);
    free(m);
}

int main(void) {
    HashMap *m = hashmap_create(8);

    hashmap_put(m, "alice", 100);
    hashmap_put(m, "bob", 200);
    hashmap_put(m, "charlie", 300);
    hashmap_put(m, "dave", 400);
    hashmap_put(m, "eve", 500);

    hashmap_print(m);

    int val;
    printf("Contains alice: %d\n", hashmap_contains(m, "alice"));
    printf("Contains frank: %d\n", hashmap_contains(m, "frank"));

    hashmap_get(m, "bob", &val);
    printf("bob -> %d\n", val);
    hashmap_get(m, "eve", &val);
    printf("eve -> %d\n", val);

    hashmap_put(m, "bob", 999);
    hashmap_get(m, "bob", &val);
    printf("bob updated -> %d\n", val);

    printf("Size before remove: %d\n", m->size);
    hashmap_remove(m, "charlie");
    printf("Size after remove: %d\n", m->size);
    printf("Contains charlie: %d\n", hashmap_contains(m, "charlie"));

    hashmap_free(m);
    printf("All tests passed.\n");
    return 0;
}
