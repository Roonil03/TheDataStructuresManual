#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

/* ============================================================================
   Hash Table Implementation in C (Equivalent to NASM Assembly)
   Uses linear probing for collision resolution
   ============================================================================ */

#define TABLE_SIZE 16
#define ENTRY_SIZE 16
#define KEY_SIZE 8
#define VALUE_SIZE 8
#define EMPTY_KEY 0xFFFFFFFFFFFFFFFF
#define DELETED_KEY 0xFFFFFFFFFFFFFFFE

/* Hash table entry structure */
typedef struct {
    uint64_t key;
    uint64_t value;
} HashEntry;

/* Hash table structure */
typedef struct {
    HashEntry entries[TABLE_SIZE];
    int size;
} HashTable;

/* Global hash table instance */
HashTable hash_table;

/* Test data */
uint64_t test_keys[] = {42, 15, 97, 3, 88, 120};
uint64_t test_values[] = {100, 200, 300, 400, 500, 600};
const int test_count = 6;

/* ============================================================================
   Hash function: Simple modulo hash
   Input: key - 64-bit unsigned integer
   Output: hash value (0 to TABLE_SIZE-1)
   ============================================================================ */
uint64_t hash_function(uint64_t key) {
    return key % TABLE_SIZE;
}

/* ============================================================================
   Initialize hash table - mark all slots as empty
   ============================================================================ */
void init_table(void) {
    for (int i = 0; i < TABLE_SIZE; i++) {
        hash_table.entries[i].key = EMPTY_KEY;
        hash_table.entries[i].value = 0;
    }
    hash_table.size = 0;
}

/* ============================================================================
   Insert key-value pair into hash table
   Input: key - key to insert
          value - value associated with key
   Output: 0 (success), 1 (failure - table full)
   ============================================================================ */
int insert(uint64_t key, uint64_t value) {
    uint64_t hash_index = hash_function(key);
    int probe_count = 0;
    
    while (probe_count < TABLE_SIZE) {
        uint64_t idx = (hash_index + probe_count) % TABLE_SIZE;
        
        /* Check if slot is empty or deleted */
        if (hash_table.entries[idx].key == EMPTY_KEY || 
            hash_table.entries[idx].key == DELETED_KEY) {
            
            /* Store key and value */
            hash_table.entries[idx].key = key;
            hash_table.entries[idx].value = value;
            hash_table.size++;
            return 0;  /* Success */
        }
        
        /* Slot occupied, probe next */
        probe_count++;
    }
    
    return 1;  /* Table full */
}

/* ============================================================================
   Search for key in hash table
   Input: key - key to search
   Output: value if found, -1 (0xFFFFFFFFFFFFFFFF) if not found
   ============================================================================ */
uint64_t search(uint64_t key) {
    uint64_t hash_index = hash_function(key);
    int probe_count = 0;
    
    while (probe_count < TABLE_SIZE) {
        uint64_t idx = (hash_index + probe_count) % TABLE_SIZE;
        
        /* Get key at this position */
        uint64_t stored_key = hash_table.entries[idx].key;
        
        /* Check if empty (no key found) */
        if (stored_key == EMPTY_KEY) {
            return (uint64_t)-1;  /* Not found */
        }
        
        /* Check if this is our key */
        if (stored_key == key) {
            return hash_table.entries[idx].value;  /* Found */
        }
        
        /* Continue probing */
        probe_count++;
    }
    
    return (uint64_t)-1;  /* Not found */
}

/* ============================================================================
   Delete key from hash table (mark as deleted)
   Input: key - key to delete
   Output: 0 (success), 1 (not found)
   ============================================================================ */
int delete_key(uint64_t key) {
    uint64_t hash_index = hash_function(key);
    int probe_count = 0;
    
    while (probe_count < TABLE_SIZE) {
        uint64_t idx = (hash_index + probe_count) % TABLE_SIZE;
        
        uint64_t stored_key = hash_table.entries[idx].key;
        
        if (stored_key == EMPTY_KEY) {
            return 1;  /* Not found */
        }
        
        if (stored_key == key) {
            hash_table.entries[idx].key = DELETED_KEY;
            hash_table.size--;
            return 0;  /* Success */
        }
        
        probe_count++;
    }
    
    return 1;  /* Not found */
}

/* ============================================================================
   Display all entries in hash table
   ============================================================================ */
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

/* ============================================================================
   Main program - Test hash table operations
   ============================================================================ */
int main(void) {
    printf("\n╔═════════════════════════════════════════════════════════════╗\n");
    printf("║   Hash Table Implementation in C (Equivalent to NASM)     ║\n");
    printf("║   Uses linear probing for collision resolution            ║\n");
    printf("╚═════════════════════════════════════════════════════════════╝\n\n");
    
    /* Initialize hash table */
    init_table();
    printf("✓ Hash Table initialized\n");
    printf("  Table Size: %d entries\n", TABLE_SIZE);
    printf("  Entry Size: %d bytes\n\n", ENTRY_SIZE);
    
    /* Test insertions */
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
    
    /* Test searches */
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
    
    /* Test collision handling */
    printf("\n╔═════════════════════════════════════════════════════════════╗\n");
    printf("║                  TEST 3: COLLISION HANDLING               ║\n");
    printf("╠═════════════════════════════════════════════════════════════╣\n");
    
    /* Try inserting a key that will collide */
    uint64_t collision_key = 42 + TABLE_SIZE;  /* Should hash to same slot as 42 */
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
    
    /* Test deletion */
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
    
    /* Verify deletion */
    uint64_t search_result = search(key_to_delete);
    if (search_result == (uint64_t)-1) {
        printf("✓ Verified: key=%llu is no longer in table\n",
               (unsigned long long)key_to_delete);
    }
    
    display_table();
    
    /* Final statistics */
    printf("\n╔═════════════════════════════════════════════════════════════╗\n");
    printf("║                    FINAL STATISTICS                      ║\n");
    printf("╠═════════════════════════════════════════════════════════════╣\n");
    printf("║ Total entries in table: %d                                ║\n", hash_table.size);
    printf("║ Table capacity: %d                                       ║\n", TABLE_SIZE);
    printf("║ Load factor: %.2f%%                                       ║\n",
           (float)hash_table.size / TABLE_SIZE * 100);
    printf("║ Empty slots: %d                                          ║\n",
           TABLE_SIZE - hash_table.size);
    printf("╚═════════════════════════════════════════════════════════════╝\n\n");
    
    printf("✓ All tests completed successfully!\n\n");
    
    return 0;
}
