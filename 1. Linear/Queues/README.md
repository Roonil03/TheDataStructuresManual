# Queues
A queue is a linear data structure that follows the First In First Out (FIFO) principle, where the element that is added first is the one to be removed first. Queues are used in various scenarios such as scheduling tasks, managing requests in a system, and handling asynchronous data.

### Basic Functions of a Queue
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

