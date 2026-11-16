/* A sorted linked chain serves lower priorities first and preserves equal-priority order. */
#include <stdio.h>
#include <stdlib.h>

typedef struct Node {
    int val;
    int priority;
    struct Node* next;
} Node;

typedef struct PriorityQueue {
    Node* head;
} PriorityQueue;

PriorityQueue* createQueue(void) {
    PriorityQueue* q = (PriorityQueue*)malloc(sizeof(PriorityQueue));
    if (q == NULL) return NULL;
    q->head = NULL;
    return q;
}

int enqueue(PriorityQueue* q, int val, int priority) {
    Node* newNode = (Node*)malloc(sizeof(Node));
    if (newNode == NULL) return 0;
    newNode->val = val;
    newNode->priority = priority;
    newNode->next = NULL;
    if (!q->head || q->head->priority > priority) {
        newNode->next = q->head;
        q->head = newNode;
    } else {
        Node* temp = q->head;
        while (temp->next && temp->next->priority <= priority) {
            temp = temp->next;
        }
        newNode->next = temp->next;
        temp->next = newNode;
    }
    return 1;
}

int dequeue(PriorityQueue* q, int *value) {
    if (!q->head) {
        return 0;
    }
    Node* temp = q->head;
    int val = temp->val;
    q->head = q->head->next;
    free(temp);
    *value = val;
    return 1;
}

int isEmpty(PriorityQueue* q) {
    return q->head == NULL;
}

void freeQueue(PriorityQueue* q) {
    Node* temp = q->head;
    while (temp) {
        Node* nextNode = temp->next;
        free(temp);
        temp = nextNode;
    }
    free(q);
}

int main(void) {
    PriorityQueue* q = createQueue();
    if (q == NULL) return EXIT_FAILURE;
    if (!enqueue(q, 10, 2) || !enqueue(q, 20, 1) || !enqueue(q, 30, 3)) {
        freeQueue(q);
        return EXIT_FAILURE;
    }
    while (!isEmpty(q)) {
        int value;
        if (dequeue(q, &value)) printf("%d ", value);
    }
    putchar('\n');
    freeQueue(q);
    return 0;
}
