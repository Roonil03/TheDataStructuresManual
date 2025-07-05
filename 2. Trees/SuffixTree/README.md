# Suffix Tree

## Overview

A **suffix tree** is a compressed trie that represents all suffixes of a given string in a space-efficient way.  By collapsing chains of single children into edges labeled with substrings, suffix trees support fast substring queries, longest-common-substring computations, and other advanced string operations in linear time relative to the pattern length.

## Key Properties

- **Structure**
Each internal node has at least two children, and edges carry substrings rather than single characters.  Leaf nodes correspond to the individual suffixes of the text.
- **Space Complexity**
A suffix tree for a string of length *n* can be stored in *O(n)* space by using edge-label compression and shared suffix links.
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
