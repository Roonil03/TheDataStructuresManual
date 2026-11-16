# Stacks
A stack is a linear data structure that follows the Last-In-First-Out (LIFO) principle. Like a stack of plates, elements can only be added or removed from the top.

### Core Operations:
1. Push - `O(1)`

    - Adds element to top of stack
    - Fails if stack is full (in array implementation)

2. Pop - `O(1)`

    - Removes and returns top element
    - Fails if stack is empty (stack underflow)

3. Peek/Top - `O(1)`

    - Views top element without removing
    - Returns null/error if stack empty

### Examples in this directory

`stacks.c` uses a linked list and accepts whitespace-separated signed `int` values. Push returns a success flag. Pop and peek return a success flag and write through an output pointer, allowing -1 to be stored normally. The program frees remaining nodes on exit, EOF, or malformed input. Display traverses the list in O(n); push, pop, and peek cost O(1).

`stacks.asm` targets Linux x86-64 NASM, accepts a digit (0–9) per whitespace-separated token, and supports push, pop, and peek. EOF exits cleanly; malformed input exits with an error. Nodes are allocated with `mmap`, and popped nodes are released with `munmap`. The kernel releases remaining mappings at exit.
