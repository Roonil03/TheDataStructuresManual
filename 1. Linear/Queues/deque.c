#include <stdio.h>
#include <stdlib.h>

#define MAX 10

typedef struct {
    int data[MAX];
    int front;
    int rear;
} Deque;

void initializeDeque(Deque* deque);
int isFull(Deque* deque);
int isEmpty(Deque* deque);
void insertFront(Deque* deque, int value);
void insertRear(Deque* deque, int value);
void deleteFront(Deque* deque);
void deleteRear(Deque* deque);
void display(Deque* deque);

int main() {
    Deque deque;
    initializeDeque(&deque);

    int choice, value;

    while (1) {
        printf("\nDouble Ended Queue Menu:\n");
        printf("1. Insert at Front\n");
        printf("2. Insert at Rear\n");
        printf("3. Delete from Front\n");
        printf("4. Delete from Rear\n");
        printf("5. Display\n");
        printf("6. Exit\n");
        printf("Enter your choice: ");
        scanf("%d", &choice);

        switch (choice) {
            case 1:
                printf("Enter value to insert at front: ");
                scanf("%d", &value);
                insertFront(&deque, value);
                break;
            case 2:
                printf("Enter value to insert at rear: ");
                scanf("%d", &value);
                insertRear(&deque, value);
                break;
            case 3:
                deleteFront(&deque);
                break;
            case 4:
                deleteRear(&deque);
                break;
            case 5:
                display(&deque);
                break;
            case 6:
                exit(0);
            default:
                printf("Invalid choice! Please try again.\n");
        }
    }

    return 0;
}

void initializeDeque(Deque* deque) {
    deque->front = -1;
    deque->rear = -1;
}

int isFull(Deque* deque) {
    return ((deque->front == 0 && deque->rear == MAX - 1) || (deque->front == deque->rear + 1));
}

int isEmpty(Deque* deque) {
    return (deque->front == -1);
}

void insertFront(Deque* deque, int value) {
    if (isFull(deque)) {
        printf("Deque is full!\n");
        return;
    }

    if (deque->front == -1) {
        deque->front = 0;
        deque->rear = 0;
    } else if (deque->front == 0) {
        deque->front = MAX - 1;
    } else {
        deque->front--;
    }

    deque->data[deque->front] = value;
    printf("Inserted %d at front.\n", value);
}

void insertRear(Deque* deque, int value) {
    if (isFull(deque)) {
        printf("Deque is full!\n");
        return;
    }

    if (deque->front == -1) {
        deque->front = 0;
        deque->rear = 0;
    } else if (deque->rear == MAX - 1) {
        deque->rear = 0;
    } else {
        deque->rear++;
    }

    deque->data[deque->rear] = value;
    printf("Inserted %d at rear.\n", value);
}

void deleteFront(Deque* deque) {
    if (isEmpty(deque)) {
        printf("Deque is empty!\n");
        return;
    }

    printf("Deleted %d from front.\n", deque->data[deque->front]);

    if (deque->front == deque->rear) {
        deque->front = -1;
        deque->rear = -1;
    } else if (deque->front == MAX - 1) {
        deque->front = 0;
    } else {
        deque->front++;
    }
}

void deleteRear(Deque* deque) {
    if (isEmpty(deque)) {
        printf("Deque is empty!\n");
        return;
    }

    printf("Deleted %d from rear.\n", deque->data[deque->rear]);

    if (deque->front == deque->rear) {
        deque->front = -1;
        deque->rear = -1;
    } else if (deque->rear == 0) {
        deque->rear = MAX - 1;
    } else {
        deque->rear--;
    }
}

void display(Deque* deque) {
    if (isEmpty(deque)) {
        printf("Deque is empty!\n");
        return;
    }

    printf("Deque elements: ");
    int i = deque->front;
    while (1) {
        printf("%d ", deque->data[i]);
        if (i == deque->rear) {
            break;
        }
        i = (i + 1) % MAX;
    }
    printf("\n");
}