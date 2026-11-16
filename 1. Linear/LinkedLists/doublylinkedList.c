/* Nodes carry next and previous links, beginning at the head pointer. */
#include "../input.h"
#include <stdlib.h>

struct Node {
    int data;
    struct Node* next;
    struct Node* prev;
};

struct Node* head = NULL;

struct Node* createNode(int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    if (newNode == NULL) return NULL;
    newNode->data = data;
    newNode->next = NULL;
    newNode->prev = NULL;
    return newNode;
}

void insertAtEnd(int data) {
    struct Node* newNode = createNode(data);
    if (newNode == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return;
    }
    if (head == NULL) {
        head = newNode;
        return;
    }
    struct Node* temp = head;
    while (temp->next != NULL)
        temp = temp->next;
    temp->next = newNode;
    newNode->prev = temp;
}

void deleteNode(int key) {
    if (head == NULL) return;

    struct Node* temp = head;
    if (head->data == key) {
        head = head->next;
        if (head != NULL)
            head->prev = NULL;
        free(temp);
        return;
    }

    while (temp != NULL && temp->data != key)
        temp = temp->next;

    if (temp == NULL) return;

    if (temp->next != NULL)
        temp->next->prev = temp->prev;

    temp->prev->next = temp->next;
    free(temp);
}

void display(void) {
    struct Node* temp = head;
    if (temp == NULL) {
        printf("List is empty\n");
        return;
    }
    while (temp != NULL) {
        printf("%d <-> ", temp->data);
        temp = temp->next;
    }
    printf("NULL\n");
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
    while (head != NULL) {
        struct Node *next = head->next;
        free(head);
        head = next;
    }
    return 0;
}
