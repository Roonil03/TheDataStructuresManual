/* The top pointer owns a chain of nodes in last-in, first-out order. */
#include "../input.h"
#include <stdlib.h>

struct Node {
    int data;
    struct Node* next;
};

struct Node* top = NULL;

int push(int value) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    if (newNode == NULL) {
        printf("Stack overflow! Memory allocation failed.\n");
        return 0;
    }
    newNode->data = value;
    newNode->next = top;
    top = newNode;
    return 1;
}

int pop(int *value) {
    if (top == NULL) {
        printf("Stack underflow! Stack is empty.\n");
        return 0;
    }

    struct Node* temp = top;
    int popped_value = temp->data;
    top = top->next;
    free(temp);
    *value = popped_value;
    return 1;
}

int peek(int *value) {
    if (top == NULL) {
        printf("Stack is empty!\n");
        return 0;
    }
    *value = top->data;
    return 1;
}

void display(void) {
    if (top == NULL) {
        printf("Stack is empty!\n");
        return;
    }

    printf("Stack contents (top to bottom):\n");
    struct Node* temp = top;
    while (temp != NULL) {
        printf("%d\n", temp->data);
        temp = temp->next;
    }
}

int main(void) {
    int choice, value;
    while (1) {
        printf("\nStack Operations:\n1. Push\n2. Pop\n3. Peek\n4. Display\n5. Exit\nEnter your choice: ");
        if (!readInteger(&choice)) break;
        switch (choice) {
            case 1:
                printf("Enter value to push: ");
                if (!readInteger(&value)) goto cleanup;
                if (push(value)) printf("Inserted %d\n", value);
                break;
            case 2:
                if (pop(&value)) printf("Popped value: %d\n", value);
                break;
            case 3:
                if (peek(&value)) printf("Top value: %d\n", value);
                break;
            case 4:
                display();
                break;
            case 5:
                goto cleanup;
            default:
                printf("Invalid choice! Please try again.\n");
        }
    }
cleanup:
    while (top != NULL) {
        struct Node *next = top->next;
        free(top);
        top = next;
    }
    return EXIT_SUCCESS;
}
