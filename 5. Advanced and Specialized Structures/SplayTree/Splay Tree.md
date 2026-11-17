# Splay Tree

`SplayTree.c` implements a self-adjusting BST of distinct integer keys. Searches splay the matching node to the root; a failed search moves the final node visited on the search path to the root. Insertions and deletions also use splaying, so the caller must retain the returned root after every operation, including search.

## Implementation

The recursive splay operation uses zig, zig-zig, and zig-zag rotations while preserving BST order. Insertion ignores an existing key; otherwise, a new root splits the splayed tree at the requested key. Deletion first splays the target; if present, it removes the root and joins its former subtrees by splaying the maximum of the left subtree before attaching the right subtree.

Each node stores one integer and two child pointers (typically 24 bytes with 4-byte integers and 8-byte pointers). No heights, colors, or parent pointers are stored. Splaying gives O(log n) amortized search/insert/delete over an operation sequence, but one operation can take O(n), and the tree can have height n. Recursive splaying and traversal use O(h) call-stack space and can exhaust it on deep trees. `freeTree` releases the tree iteratively without extra allocated storage. Allocation failure prints an error and terminates.

Splay trees are useful when recently accessed keys are likely to be accessed again. They do not guarantee a logarithmic worst-case response time for an individual operation. Stored space is O(n); traversal/destruction take O(n) time.

## Run

```sh
cc -std=c11 -Wall -Wextra -Wpedantic SplayTree.c -o /tmp/splay-tree
/tmp/splay-tree
```

Commands are `i <key>` (insert), `d <key>` (delete), `s <key>` (search), `p` (preorder), `n` (inorder), and `q` (quit), as whitespace-separated tokens. Commands must be single characters; combined tokens such as `i5` and `np` are invalid. EOF, an invalid/missing integer operand, a command token longer than one byte or containing a NUL byte, and `q` end the session and free the tree. Other unrecognized single-character commands are ignored. Keys must be complete decimal tokens with an optional sign and must fit in `int`; arbitrarily many leading zeros are accepted.
