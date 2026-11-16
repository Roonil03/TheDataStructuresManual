/* The fixed array stores five signed integers in contiguous memory. */
#include "../input.h"

int main(void) {
    int arr[5];
    int i;
    printf("Enter 5 integers:\n");
    for (i = 0; i < 5; i++) {
        printf("Enter integer %d: ", i + 1);
        if (!readInteger(&arr[i])) return EXIT_FAILURE;
    }
    printf("You entered:\n");
    for (i = 0; i < 5; i++) {
        printf("Element %d: %d\n", i + 1, arr[i]);
    }
    return 0;
}
