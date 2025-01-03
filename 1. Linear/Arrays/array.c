#include <stdio.h>

int main() {
    int arr[5];
    int i;
    printf("Enter 5 integers:\n");
    for (i = 0; i < 5; i++) {
        printf("Enter integer %d: ", i + 1);
        scanf("%d", &arr[i]);
    }
    printf("You entered:\n");
    for (i = 0; i < 5; i++) {
        printf("Element %d: %d\n", i + 1, arr[i]);
    }
    return 0;
}