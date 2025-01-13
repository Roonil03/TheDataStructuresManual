#include <stdio.h>
#include <stdlib.h>

struct Node {
    int data;
    struct Node* next;
};

struct Node* front = NULL;
struct Node* rear = NULL;

void enqueue(int value) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    if (newNode == NULL) {
        printf("Queue overflow! Memory allocation failed.\n");
        return;
    }
    newNode->data = value;
    newNode->next = NULL;
    if (rear == NULL) {
        front = rear = newNode;
        return;
    }
    rear->next = newNode;
    rear = newNode;
}

int dequeue() {
    if (front == NULL) {
        printf("Queue underflow! Queue is empty.\n");
        return -1;
    }
    struct Node* temp = front;
    int dequeuedValue = temp->data;
    front = front->next;
    if (front == NULL) {
        rear = NULL;
    }
    free(temp);
    return dequeuedValue;
}

int peek() {
    if (front == NULL) {
        printf("Queue is empty!\n");
        return -1;
    }
    return front->data;
}

void displayQueue() {
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

void clearInputBuffer() {
    int c;
    while ((c = getchar()) != '\n' && c != EOF);
}

int main() {
    int choice, value;

    while (1) {
        printf("\nQueue Operations:\n");
        printf("1. Enqueue\n");
        printf("2. Dequeue\n");
        printf("3. Peek\n");
        printf("4. Display Queue\n");
        printf("5. Exit\n");
        printf("Enter your choice: ");

        if (scanf("%d", &choice) != 1) {
            printf("Invalid input! Please enter a number.\n");
            clearInputBuffer();
            continue;
        }

        switch (choice) {
            case 1:
                printf("Enter value to enqueue: ");
                if (scanf("%d", &value) != 1) {
                    printf("Invalid input! Please enter a number.\n");
                    clearInputBuffer();
                    break;
                }
                enqueue(value);
                printf("%d enqueued to queue\n", value);
                break;

            case 2:
                value = dequeue();
                if (value != -1) {
                    printf("Dequeued value: %d\n", value);
                }
                break;

            case 3:
                value = peek();
                if (value != -1) {
                    printf("Front value: %d\n", value);
                }
                break;

            case 4:
                displayQueue();
                break;

            case 5:
                printf("Exiting program...\n");
                while (front != NULL) {
                    struct Node* temp = front;
                    front = front->next;
                    free(temp);
                }
                exit(0);

            default:
                printf("Invalid choice! Please try again.\n");
        }

        clearInputBuffer();
    }

    return 0;
}