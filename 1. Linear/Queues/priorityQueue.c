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

PriorityQueue* createQueue() {
    PriorityQueue* q = (PriorityQueue*)malloc(sizeof(PriorityQueue));
    q->head = NULL;
    return q;
}

void enqueue(PriorityQueue* q, int val, int priority) {
    Node* newNode = (Node*)malloc(sizeof(Node));
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
}

int dequeue(PriorityQueue* q) {
    if (!q->head) {
        return -1;
    }
    Node* temp = q->head;
    int val = temp->val;
    q->head = q->head->next;
    free(temp);
    return val;
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

int main() {
    PriorityQueue* q = createQueue();
    enqueue(q, 10, 2);
    enqueue(q, 20, 1);
    enqueue(q, 30, 3);
    while (!isEmpty(q)) {
        printf("%d ", dequeue(q));
    }
    freeQueue(q);
    return 0;
}
