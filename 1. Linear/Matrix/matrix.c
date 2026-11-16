/* The fixed matrix stores five rows of five signed integers. */
#include "../input.h"

int main(void) {
    int matrix[5][5];
    int i, j;
    printf("Please enter 25 numbers to fill a 5x5 matrix:\n");
    for (i = 0; i < 5; i++) {
        for (j = 0; j < 5; j++) {
            printf("Enter number for matrix[%d][%d]: ", i, j);
            if (!readInteger(&matrix[i][j])) return EXIT_FAILURE;
        }
    }
    printf("\nThe 5x5 matrix is:\n");
    for (i = 0; i < 5; i++) {
        for (j = 0; j < 5; j++) {
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
    }

    return 0;
}
