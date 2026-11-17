# Hash map

Each bucket holds a singly linked chain of key-value pairs. An insertion scans the chain for an existing key and updates its value if found. A new entry goes at the head. Removal unlinks a single entry. Both examples use a fixed positive bucket count.

## Keys and storage

The C example maps strings to integers. It hashes the bytes with djb2 and takes the remainder modulo the bucket count. The map owns a copy of each key, freed on removal or destruction. `hashmap_put` returns 1 on success and 0 on failure. The assembly example uses signed 32-bit integer keys and values. Its bucket index is the magnitude of the signed remainder.

On x86-64 both map headers take 16 bytes and each bucket head takes 8 bytes. A C entry takes 24 bytes including padding, plus the allocated key string. An assembly entry takes 16 bytes. In both implementations `hashmap_get` returns 1 and writes the value on a hit. It returns 0 on a miss.

## Complexity

With uniformly distributed hashes, a chain has expected length n / b for n entries and b buckets. Lookup, update and removal examine O(1 + n / b) entries on average and O(n) in the worst case. String hashing also reads the input key, and string comparisons may read matching prefixes. Storage is O(b + n) plus the bytes in the C keys.
