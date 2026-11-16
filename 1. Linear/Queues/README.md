# Queues
A queue is a linear data structure that follows the First In First Out (FIFO) principle, where the element that is added first is the one to be removed first. Queues are used in various scenarios such as scheduling tasks, managing requests in a system, and handling asynchronous data.

### Basic Functions of a FIFO Queue
These bounds apply to the FIFO implementations below; priority queue insertion has a different bound.

- Enqueue: Add an element to the end of the queue.
    - Time Complexity: O(1)
    - Space Complexity: O(1) per element added
- Dequeue: Remove an element from the front of the queue.
    - Time Complexity: O(1)
    - Space Complexity: O(1) per element removed
- Peek/Front: Get the front element of the queue without removing it.
    - Time Complexity: O(1)
    - Space Complexity: O(1)
- isEmpty: Check whether the queue is empty.
    - Time Complexity: O(1)
    - Space Complexity: O(1)
- isFull (for fixed size queues): Check whether the queue is full.
    - Time Complexity: O(1)
    - Space Complexity: O(1)
### Types of Queues
1. Simple Queue:

    - Linear FIFO structure.
    - Basic operations: enqueue, dequeue, peek, isEmpty.
    - Use cases: Basic task scheduling, buffering.
2. Circular Queue:

    - Efficient use of space by wrapping around.
    - Additional method: isFull.
    - Use cases: Memory management, buffering that wraps around.
3. Priority Queue:

    - Elements dequeued based on priority.
    - Additional methods: peekMax/peekMin, enqueue with priority.
    - Use cases: Task scheduling with priority, shortest path algorithms.
4. Deque (Double-ended Queue):

    - Allows insertion and removal from both ends.
    - Additional methods: addFront, addRear, removeFront, removeRear.
    - Use cases: Palindrome checking, flexible data structure for both stack and queue operations.

### Examples in this directory

`simpleQueue.c` uses a linked FIFO queue; `circularQueue.c` uses a circular array with capacity 5; `deque.c` uses a circular array with capacity 10. Their core insertion and removal operations cost O(1); the two FIFO queues also provide O(1) peek operations. Display costs O(n). Interactive C examples accept whitespace-separated signed `int` values, including -1, and release allocated memory when input ends or is malformed. In the two FIFO queues, removal and peek return a success flag and write the value through an output pointer, keeping empty state distinct from stored -1. The deque prints removed values directly and has no peek operation.

`priorityQueue.c` maintains a sorted linked list. Smaller priority numbers are served first, and equal priorities retain insertion order. Insertion is O(n), while removal from the front is O(1). Its fixed demonstration prints `20 10 30`.

The `.asm` examples target Linux x86-64 NASM and accept one digit (0–9) per whitespace-separated token. EOF exits cleanly and malformed input exits with an error. `circularQueue.asm` has capacity 5; `simpleQueue.asm`, `deque.asm`, and `prioritQueue.asm` allocate linked nodes with `mmap` and release removed nodes with `munmap`. The kernel releases remaining live nodes at exit. Assembly priority ordering also serves smaller numbers first with stable ties. Its display concatenates each value and priority as two digits (for example, value 7 with priority 2 appears as `72`).
