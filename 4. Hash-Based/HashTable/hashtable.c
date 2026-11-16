/* Linear probing uses two reserved keys for empty and deleted slots. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define TABLE_SIZE 16
#define ENTRY_SIZE 16
#define KEY_SIZE 8
#define VALUE_SIZE 8
#define EMPTY_KEY 0xFFFFFFFFFFFFFFFF
#define DELETED_KEY 0xFFFFFFFFFFFFFFFE

typedef struct {
    uint64_t key;
    uint64_t value;
} HashEntry;

typedef struct {
    HashEntry entries[TABLE_SIZE];
    int size;
} HashTable;

HashTable hash_table;

uint64_t test_keys[] = {42, 15, 97, 3, 88, 120};
uint64_t test_values[] = {100, 200, 300, 400, 500, 600};
const int test_count = 6;

uint64_t hash_function(uint64_t key) {
    return key % TABLE_SIZE;
}

void init_table(void) {
    for (int i = 0; i < TABLE_SIZE; i++) {
        hash_table.entries[i].key = EMPTY_KEY;
        hash_table.entries[i].value = 0;
    }
    hash_table.size = 0;
}

int insert(uint64_t key, uint64_t value) {
    if (key == EMPTY_KEY || key == DELETED_KEY) return 1;
    int slot = -1;
    for (int probe = 0; probe < TABLE_SIZE; probe++) {
        int idx = (hash_function(key) + probe) % TABLE_SIZE;
        uint64_t stored = hash_table.entries[idx].key;
        if (stored == key) {
            hash_table.entries[idx].value = value;
            return 0;
        }
        if (slot < 0 && (stored == EMPTY_KEY || stored == DELETED_KEY)) slot = idx;
        if (stored == EMPTY_KEY) break;
    }
    if (slot < 0) return 1;
    hash_table.entries[slot] = (HashEntry){key, value};
    hash_table.size++;
    return 0;
}

uint64_t search(uint64_t key) {
    if (key == DELETED_KEY) return UINT64_MAX;
    uint64_t hash_index = hash_function(key);
    int probe_count = 0;

    while (probe_count < TABLE_SIZE) {
        uint64_t idx = (hash_index + probe_count) % TABLE_SIZE;

        uint64_t stored_key = hash_table.entries[idx].key;

        if (stored_key == EMPTY_KEY) {
            return (uint64_t)-1;
        }

        if (stored_key == key) {
            return hash_table.entries[idx].value;
        }

        probe_count++;
    }

    return (uint64_t)-1;
}

int delete_key(uint64_t key) {
    if (key == DELETED_KEY) return 1;
    uint64_t hash_index = hash_function(key);
    int probe_count = 0;

    while (probe_count < TABLE_SIZE) {
        uint64_t idx = (hash_index + probe_count) % TABLE_SIZE;

        uint64_t stored_key = hash_table.entries[idx].key;

        if (stored_key == EMPTY_KEY) {
            return 1;
        }

        if (stored_key == key) {
            hash_table.entries[idx].key = DELETED_KEY;
            hash_table.size--;
            return 0;
        }

        probe_count++;
    }

    return 1;
}

void display_table(void) {
    printf("\n╔════════════════════════════════════════════╗\n");
    printf("║         Hash Table Contents (Size: %d)    ║\n", hash_table.size);
    printf("╠════════════════════════════════════════════╣\n");

    for (int i = 0; i < TABLE_SIZE; i++) {
        printf("║ Slot %2d: ", i);

        if (hash_table.entries[i].key == EMPTY_KEY) {
            printf("[EMPTY]                         ║\n");
        } else if (hash_table.entries[i].key == DELETED_KEY) {
            printf("[DELETED]                       ║\n");
        } else {
            printf("Key: %3llu, Value: %3llu        ║\n",
                   (unsigned long long)hash_table.entries[i].key,
                   (unsigned long long)hash_table.entries[i].value);
        }
    }

    printf("╚════════════════════════════════════════════╝\n");
}

int main(void) {
    printf("\n╔═════════════════════════════════════════════════════════════╗\n");
    printf("║   Hash Table Implementation in C (Equivalent to NASM)     ║\n");
    printf("║   Uses linear probing for collision resolution            ║\n");
    printf("╚═════════════════════════════════════════════════════════════╝\n\n");

    init_table();
    printf("✓ Hash Table initialized\n");
    printf("  Table Size: %d entries\n", TABLE_SIZE);
    printf("  Entry Size: %d bytes\n\n", ENTRY_SIZE);

    printf("╔═════════════════════════════════════════════════════════════╗\n");
    printf("║                      TEST 1: INSERT                        ║\n");
    printf("╠═════════════════════════════════════════════════════════════╣\n");

    for (int i = 0; i < test_count; i++) {
        uint64_t key = test_keys[i];
        uint64_t value = test_values[i];

        int result = insert(key, value);

        if (result == 0) {
            printf("✓ Inserted: key=%llu, value=%llu\n",
                   (unsigned long long)key, (unsigned long long)value);
        } else {
            printf("✗ Failed: Table full (key=%llu)\n",
                   (unsigned long long)key);
        }
    }

    display_table();

    printf("\n╔═════════════════════════════════════════════════════════════╗\n");
    printf("║                      TEST 2: SEARCH                       ║\n");
    printf("╠═════════════════════════════════════════════════════════════╣\n");

    int search_passed = 0;
    int search_failed = 0;

    for (int i = 0; i < test_count; i++) {
        uint64_t key = test_keys[i];
        uint64_t expected_value = test_values[i];

        uint64_t found_value = search(key);

        if (found_value != (uint64_t)-1) {
            if (found_value == expected_value) {
                printf("✓ Found: key=%llu, value=%llu (Expected: %llu)\n",
                       (unsigned long long)key,
                       (unsigned long long)found_value,
                       (unsigned long long)expected_value);
                search_passed++;
            } else {
                printf("✗ Mismatch: key=%llu, found=%llu, expected=%llu\n",
                       (unsigned long long)key,
                       (unsigned long long)found_value,
                       (unsigned long long)expected_value);
                search_failed++;
            }
        } else {
            printf("✗ Not found: key=%llu (Expected: %llu)\n",
                   (unsigned long long)key,
                   (unsigned long long)expected_value);
            search_failed++;
        }
    }

    printf("\nSearch Results: %d passed, %d failed\n", search_passed, search_failed);

    printf("\n╔═════════════════════════════════════════════════════════════╗\n");
    printf("║                  TEST 3: COLLISION HANDLING               ║\n");
    printf("╠═════════════════════════════════════════════════════════════╣\n");

    uint64_t collision_key = 42 + TABLE_SIZE;
    uint64_t collision_value = 999;

    printf("Attempting collision test:\n");
    printf("  Original key (42) hashes to: %llu\n",
           (unsigned long long)hash_function(42));
    printf("  Collision key (%llu) hashes to: %llu\n",
           (unsigned long long)collision_key,
           (unsigned long long)hash_function(collision_key));

    int result = insert(collision_key, collision_value);
    if (result == 0) {
        printf("✓ Collision handled successfully via linear probing\n");
        printf("✓ Inserted: key=%llu, value=%llu\n",
               (unsigned long long)collision_key,
               (unsigned long long)collision_value);
    } else {
        printf("✗ Failed to handle collision\n");
    }

    display_table();

    printf("\n╔═════════════════════════════════════════════════════════════╗\n");
    printf("║                      TEST 4: DELETE                       ║\n");
    printf("╠═════════════════════════════════════════════════════════════╣\n");

    uint64_t key_to_delete = 15;
    printf("Deleting key=%llu\n", (unsigned long long)key_to_delete);

    int delete_result = delete_key(key_to_delete);
    if (delete_result == 0) {
        printf("✓ Successfully deleted key=%llu\n",
               (unsigned long long)key_to_delete);
    } else {
        printf("✗ Failed to delete key=%llu (not found)\n",
               (unsigned long long)key_to_delete);
    }

    uint64_t search_result = search(key_to_delete);
    if (search_result == (uint64_t)-1) {
        printf("✓ Verified: key=%llu is no longer in table\n",
               (unsigned long long)key_to_delete);
    }

    display_table();

    printf("\n╔═════════════════════════════════════════════════════════════╗\n");
    printf("║                    FINAL STATISTICS                      ║\n");
    printf("╠═════════════════════════════════════════════════════════════╣\n");
    printf("║ Total entries in table: %d                                ║\n", hash_table.size);
    printf("║ Table capacity: %d                                       ║\n", TABLE_SIZE);
    printf("║ Load factor: %.2f%%                                       ║\n",
           (float)hash_table.size / TABLE_SIZE * 100);
    printf("║ Available slots: %d                                          ║\n",
           TABLE_SIZE - hash_table.size);
    printf("╚═════════════════════════════════════════════════════════════╝\n\n");

    return search_failed || result || delete_result || search_result != UINT64_MAX;
}
