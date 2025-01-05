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