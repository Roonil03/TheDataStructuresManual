/* Front and rear delimit a linked chain in first-in, first-out order. */
#include "../input.h"
#include <stdlib.h>

struct Node {
    int data;
    struct Node* next;
};

struct Node* front = NULL;
struct Node* rear = NULL;

int enqueue(int value) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    if (newNode == NULL) {
        printf("Queue overflow! Memory allocation failed.\n");
        return 0;
    }
    newNode->data = value;
    newNode->next = NULL;
    if (rear == NULL) {
        front = rear = newNode;
        return 1;
    }
    rear->next = newNode;
    rear = newNode;
    return 1;
}

int dequeue(int *value) {
    if (front == NULL) {
        printf("Queue underflow! Queue is empty.\n");
        return 0;
    }
    struct Node* temp = front;
    int dequeuedValue = temp->data;
    front = front->next;
    if (front == NULL) {
        rear = NULL;
    }
    free(temp);
    *value = dequeuedValue;
    return 1;
}

int peek(int *value) {
    if (front == NULL) {
        printf("Queue is empty!\n");
        return 0;
    }
    *value = front->data;
    return 1;
}

void displayQueue(void) {
    if (front == NULL) {
        printf("Queue is empty!\n");
        return;
    }
    printf("Queue contents (front to rear):\n");
    struct Node* temp = front;
    while (temp != NULL) {
        printf("%d ", temp->data);
        temp = temp->next;
    }
    printf("\n");
}

int main(void) {
    int choice, value;
    while (1) {
        printf("\nQueue Operations:\n1. Enqueue\n2. Dequeue\n3. Peek\n4. Display\n5. Exit\nEnter your choice: ");
        if (!readInteger(&choice)) break;
        switch (choice) {
            case 1:
                printf("Enter value to enqueue: ");
                if (!readInteger(&value)) goto cleanup;
                if (enqueue(value)) printf("Inserted %d\n", value);
                break;
            case 2:
                if (dequeue(&value)) printf("Dequeued value: %d\n", value);
                break;
            case 3:
                if (peek(&value)) printf("Front value: %d\n", value);
                break;
            case 4:
                displayQueue();
                break;
            case 5:
                goto cleanup;
            default:
                printf("Invalid choice! Please try again.\n");
        }
    }
cleanup:
    while (front != NULL) {
        struct Node *next = front->next;
        free(front);
        front = next;
    }
    rear = NULL;
    return EXIT_SUCCESS;
}
