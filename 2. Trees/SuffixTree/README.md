# Suffix Tree

## Included programs

`SuffixTree.c` reads a text token and a pattern token, each at most 999 bytes, then prints `Found` or `Not found`. It builds a naive compressed suffix trie (an implicit suffix tree), inserting suffixes independently in O(n²) time. Substring search takes O(m) for pattern length m. The fixed 256-way child arrays use O(n) nodes for a fixed byte alphabet. It does not implement Ukkonen’s algorithm, active points, maintained suffix links, a unique terminator, suffix enumeration, occurrence counts, or longest-repeated-substring output. Suffixes that end within an edge need no explicit marker for the implemented substring-existence query.

`SuffixTree.asm` reads a text token of up to 999 bytes and a pattern token of up to 255 bytes. It builds a compact suffix tree by inserting suffixes from left to right. A node stores an edge’s start and exclusive end offsets, its first child, its next sibling, and the earliest suffix position below it. A mismatch inside an edge splits that edge. A successful query prints the earliest zero-based match. A miss prints `Pattern not found`. For a fixed byte alphabet, construction takes O(n²) time and lookup takes O(m) time. At most two nodes are added per suffix.

Both drivers read complete whitespace-separated tokens. A missing field, an overlong token, or an embedded NUL byte ends the session with an error.

Build from this directory (outputs stay in `/tmp`):

```sh
gcc -std=c11 -Wall -Wextra "SuffixTree.c" -o /tmp/suffixtree
nasm -f elf64 "SuffixTree.asm" -o /tmp/tree.o
gcc -no-pie /tmp/tree.o -o /tmp/tree-asm
```

## Overview

A **suffix tree** is a compressed trie that represents all suffixes of a given string in a space-efficient way.  By collapsing chains of single children into edges labeled with substrings, a suffix tree can answer substring queries in time proportional to the pattern length for a fixed alphabet. A generalized suffix tree can also compare multiple strings.

## Key Properties

- **Structure**
In an explicit suffix tree built with a unique terminator, each suffix has its own leaf and each non-root internal node has at least two children. In the implicit trees used here, a suffix can end partway along another suffix’s path.
- **Space Complexity**
A suffix tree for a string of length *n* can be stored in *O(n)* space by storing compressed edge labels as intervals in the original text. Suffix links accelerate construction.
- **Construction Time**
Ukkonen’s algorithm builds the suffix tree in *O(n)* time for constant-size alphabets by iteratively adding suffixes and maintaining an “active point” for efficient extension.


## Core Operations

### 1. Substring Search

Traverse from the root, matching edge labels character by character.  If the pattern’s characters are found along a path, the search succeeds in *O(m)* time for a pattern of length *m*; otherwise it fails as soon as a mismatch occurs.

### 2. Longest Repeated Substring

Perform a depth-first search to find the deepest internal node; the concatenation of edge labels along the path to that node yields the longest repeated substring in the text in *O(n)* time.

### 3. Longest Common Substring (Two Strings)

Build a generalized suffix tree for both strings (concatenated with unique end markers).  Then locate the deepest internal node whose descendant leaves include suffixes from both strings; the path to that node is the longest common substring.

## Algorithmic Techniques

### Ukkonen’s Online Construction

- Maintains an **active point** (active node, edge, and length) to avoid restarting matches for each new suffix
- Uses **suffix links** to jump between internal nodes sharing common suffixes, ensuring linear-time performance
- Splits edges when necessary to insert new extension points without re-scanning from the root


### Suffix Links

An auxiliary pointer from one internal node to another whose path label is the original’s path label minus the first character; these links enable *O(1)* amortized transitions between extension contexts.

## Practical Considerations

- **Alphabet Size**: Large alphabets may increase constant factors in construction time; use integer mapping or direct indexing as appropriate.
- **Memory Usage**: Although asymptotically linear, the node and edge overhead can be significant in practice; careful implementation with compact representations is essential.
- **Applications**: Bioinformatics (DNA sequence analysis), data compression (LZ77/LZ78 variants), plagiarism detection, substring indexing in databases.
