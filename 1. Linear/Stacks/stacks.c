#include <stdio.h>
#include <stdlib.h>

struct Node {
    int data;
    struct Node* next;
};

struct Node* top = NULL;

void push(int value) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    if (newNode == NULL) {
        printf("Stack overflow! Memory allocation failed.\n");
        return;
    }
    newNode->data = value;
    newNode->next = top;
    top = newNode;
}

int pop() {
    if (top == NULL) {
        printf("Stack underflow! Stack is empty.\n");
        return -1;
    }
    
    struct Node* temp = top;
    int popped_value = temp->data;
    top = top->next;
    free(temp);
    return popped_value;
}

int peek() {
    if (top == NULL) {
        printf("Stack is empty!\n");
        return -1;
    }
    return top->data;
}

void display() {
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

void clearInputBuffer() {
    int c;
    while ((c = getchar()) != '\n' && c != EOF);
}

int main() {
    int choice, value;
    
    while (1) {
        printf("\nStack Operations:\n");
        printf("1. Push\n");
        printf("2. Pop\n");
        printf("3. Peek\n");
        printf("4. Display Stack\n");
        printf("5. Exit\n");
        printf("Enter your choice: ");
        
        if (scanf("%d", &choice) != 1) {
            printf("Invalid input! Please enter a number.\n");
            clearInputBuffer();
            continue;
        }
        
        switch (choice) {
            case 1:
                printf("Enter value to push: ");
                if (scanf("%d", &value) != 1) {
                    printf("Invalid input! Please enter a number.\n");
                    clearInputBuffer();
                    break;
                }
                push(value);
                printf("%d pushed to stack\n", value);
                break;
                
            case 2:
                value = pop();
                if (value != -1) {
                    printf("Popped value: %d\n", value);
                }
                break;
                
            case 3:
                value = peek();
                if (value != -1) {
                    printf("Top value: %d\n", value);
                }
                break;
                
            case 4:
                display();
                break;
                
            case 5:
                printf("Exiting program...\n");
                while (top != NULL) {
                    struct Node* temp = top;
                    top = top->next;
                    free(temp);
                }
                exit(0);
                
            default:
                printf("Invalid choice! Please try again.\n");
        }        
        clearInputBuffer();
    }    
    return EXIT_SUCCESS;
}