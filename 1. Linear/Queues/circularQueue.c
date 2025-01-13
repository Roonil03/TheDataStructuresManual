#include <stdio.h>
#include <stdlib.h>

#define SIZE 5

struct CircularQueue {
    int items[SIZE];
    int front, rear;
};

struct CircularQueue* createQueue() {
    struct CircularQueue* queue = (struct CircularQueue*)malloc(sizeof(struct CircularQueue));
    queue->front = -1;
    queue->rear = -1;
    return queue;
}

int isFull(struct CircularQueue* queue) {
    if ((queue->front == 0 && queue->rear == SIZE - 1) || (queue->rear == (queue->front - 1) % (SIZE - 1))) {
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

int dequeue(struct CircularQueue* queue) {
    if (isEmpty(queue)) {
        printf("Queue is empty\n");
        return -1;
    }
    int item = queue->items[queue->front];
    if (queue->front == queue->rear) {
        queue->front = -1;
        queue->rear = -1;
    } else {
        queue->front = (queue->front + 1) % SIZE;
    }
    return item;
}

int peek(struct CircularQueue* queue) {
    if (isEmpty(queue)) {
        printf("Queue is empty\n");
        return -1;
    }
    return queue->items[queue->front];
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

int main() {
    struct CircularQueue* queue = createQueue();
    int choice, value;
    
    while (1) {
        printf("\nCircular Queue Operations:\n");
        printf("1. Enqueue\n");
        printf("2. Dequeue\n");
        printf("3. Peek\n");
        printf("4. Display Queue\n");
        printf("5. Exit\n");
        printf("Enter your choice: ");
        scanf("%d", &choice);
        
        switch (choice) {
            case 1:
                printf("Enter value to enqueue: ");
                scanf("%d", &value);
                enqueue(queue, value);
                break;
                
            case 2:
                value = dequeue(queue);
                if (value != -1) {
                    printf("Dequeued value: %d\n", value);
                }
                break;
                
            case 3:
                value = peek(queue);
                if (value != -1) {
                    printf("Front value: %d\n", value);
                }
                break;
                
            case 4:
                displayQueue(queue);
                break;
                
            case 5:
                free(queue);
                exit(0);
                
            default:
                printf("Invalid choice! Please try again.\n");
        }
    }
    
    return 0;
}