/* The last node links back to the first node in a circular chain. */
#include "../input.h"
#include <stdlib.h>

struct Node {
    int data;
    struct Node* next;
};

struct Node* last = NULL;

struct Node* createNode(int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    if (newNode == NULL) return NULL;
    newNode->data = data;
    newNode->next = newNode;
    return newNode;
}

void insertAtEnd(int data) {
    struct Node* newNode = createNode(data);
    if (newNode == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return;
    }

    if (last == NULL) {
        last = newNode;
        return;
    }

    newNode->next = last->next;
    last->next = newNode;
    last = newNode;
}

void deleteNode(int key) {
    if (last == NULL) return;

    struct Node* current = last->next;
    struct Node* prev = last;

    if (current->data == key && current == last->next && current == last) {
        free(current);
        last = NULL;
        return;
    }

    do {
        if (current->data == key) {
            if (current == last) {
                last = prev;
            }
            prev->next = current->next;
            free(current);
            return;
        }
        prev = current;
        current = current->next;
    } while (current != last->next);
}

void display(void) {
    if (last == NULL) {
        printf("List is empty\n");
        return;
    }

    struct Node* temp = last->next;
    do {
        printf("%d -> ", temp->data);
        temp = temp->next;
    } while (temp != last->next);
    printf("(First Node)\n");
}

int main(void) {
    int choice, data;

    while (1) {
        printf("\n1. Insert\n2. Delete\n3. Display\n4. Exit\n");
        printf("Enter your choice: ");
        if (!readInteger(&choice)) goto cleanup;

        switch (choice) {
            case 1:
                printf("Enter data to insert: ");
                if (!readInteger(&data)) goto cleanup;
                insertAtEnd(data);
                break;

            case 2:
                printf("Enter data to delete: ");
                if (!readInteger(&data)) goto cleanup;
                deleteNode(data);
                break;

            case 3:
                display();
                break;

            case 4:
                goto cleanup;

            default:
                printf("Invalid choice\n");
        }
    }
cleanup:
    if (last != NULL) {
        struct Node *current = last->next;
        last->next = NULL;
        while (current != NULL) {
            struct Node *next = current->next;
            free(current);
            current = next;
        }
        last = NULL;
    }
    return 0;
}
