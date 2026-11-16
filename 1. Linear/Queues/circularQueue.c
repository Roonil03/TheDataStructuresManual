/* Front and rear index a five-element circular array; -1 marks empty state. */
#include "../../common/input.h"
#include <stdlib.h>

#define SIZE 5

struct CircularQueue {
    int items[SIZE];
    int front, rear;
};

struct CircularQueue* createQueue(void) {
    struct CircularQueue* queue = (struct CircularQueue*)malloc(sizeof(struct CircularQueue));
    if (queue == NULL) return NULL;
    queue->front = -1;
    queue->rear = -1;
    return queue;
}

int isFull(struct CircularQueue* queue) {
    if ((queue->rear + 1) % SIZE == queue->front) {
        return 1;
    }
    return 0;
}

int isEmpty(struct CircularQueue* queue) {
    if (queue->front == -1) {
        return 1;
    }
    return 0;
}

void enqueue(struct CircularQueue* queue, int value) {
    if (isFull(queue)) {
        printf("Queue is full\n");
        return;
    }
    if (queue->front == -1) {
        queue->front = 0;
    }
    queue->rear = (queue->rear + 1) % SIZE;
    queue->items[queue->rear] = value;
    printf("Inserted %d\n", value);
}

int dequeue(struct CircularQueue* queue, int *value) {
    if (isEmpty(queue)) {
        printf("Queue is empty\n");
        return 0;
    }
    int item = queue->items[queue->front];
    if (queue->front == queue->rear) {
        queue->front = -1;
        queue->rear = -1;
    } else {
        queue->front = (queue->front + 1) % SIZE;
    }
    *value = item;
    return 1;
}

int peek(struct CircularQueue* queue, int *value) {
    if (isEmpty(queue)) {
        printf("Queue is empty\n");
        return 0;
    }
    *value = queue->items[queue->front];
    return 1;
}

void displayQueue(struct CircularQueue* queue) {
    if (isEmpty(queue)) {
        printf("Queue is empty\n");
        return;
    }
    int i = queue->front;
    printf("Queue elements are:\n");
    while (1) {
        printf("%d ", queue->items[i]);
        if (i == queue->rear) {
            break;
        }
        i = (i + 1) % SIZE;
    }
    printf("\n");
}

int main(void) {
    struct CircularQueue* queue = createQueue();
    if (queue == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return EXIT_FAILURE;
    }
    int choice, value;

    while (1) {
        printf("\nCircular Queue Operations:\n");
        printf("1. Enqueue\n");
        printf("2. Dequeue\n");
        printf("3. Peek\n");
        printf("4. Display Queue\n");
        printf("5. Exit\n");
        printf("Enter your choice: ");
        if (!readInteger(&choice)) goto cleanup;

        switch (choice) {
            case 1:
                printf("Enter value to enqueue: ");
                if (!readInteger(&value)) goto cleanup;
                enqueue(queue, value);
                break;

            case 2:
                if (dequeue(queue, &value)) {
                    printf("Dequeued value: %d\n", value);
                }
                break;

            case 3:
                if (peek(queue, &value)) {
                    printf("Front value: %d\n", value);
                }
                break;

            case 4:
                displayQueue(queue);
                break;

            case 5:
                goto cleanup;

            default:
                printf("Invalid choice! Please try again.\n");
        }
    }

cleanup:
    free(queue);
    return 0;
}
