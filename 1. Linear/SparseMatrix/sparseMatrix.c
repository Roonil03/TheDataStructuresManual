/* Sparse formats store nonzero values and indices instead of dense cells. */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>

typedef struct {
    int row;
    int col;
    int value;
} Element;

typedef struct {
    int rows;
    int cols;
    int nonZeroCount;
    int *values;
    int *colIndex;
    int *rowPtr;
} CSR;

typedef struct {
    int rows;
    int cols;
    int nonZeroCount;
    int *values;
    int *rowIndex;
    int *colPtr;
} CSC;

typedef struct {
    int nonZeroCount;
    Element *elements;
} COO;

void printCSR(CSR *csr) {
    printf("CSR Format:\n");
    printf("Values: ");
    for (int i = 0; i < csr->nonZeroCount; i++) {
        printf("%d ", csr->values[i]);
    }
    printf("\nColumn Indices: ");
    for (int i = 0; i < csr->nonZeroCount; i++) {
        printf("%d ", csr->colIndex[i]);
    }
    printf("\nRow Pointers: ");
    for (int i = 0; i <= csr->rows; i++) {
        printf("%d ", csr->rowPtr[i]);
    }
    printf("\n");
}

void printCSC(CSC *csc) {
    printf("CSC Format:\n");
    printf("Values: ");
    for (int i = 0; i < csc->nonZeroCount; i++) {
        printf("%d ", csc->values[i]);
    }
    printf("\nRow Indices: ");
    for (int i = 0; i < csc->nonZeroCount; i++) {
        printf("%d ", csc->rowIndex[i]);
    }
    printf("\nColumn Pointers: ");
    for (int i = 0; i <= csc->cols; i++) {
        printf("%d ", csc->colPtr[i]);
    }
    printf("\n");
}

void printCOO(COO *coo) {
    printf("COO Format:\n");
    printf("Row Indices: ");
    for (int i = 0; i < coo->nonZeroCount; i++) {
        printf("%d ", coo->elements[i].row);
    }
    printf("\nColumn Indices: ");
    for (int i = 0; i < coo->nonZeroCount; i++) {
        printf("%d ", coo->elements[i].col);
    }
    printf("\nValues: ");
    for (int i = 0; i < coo->nonZeroCount; i++) {
        printf("%d ", coo->elements[i].value);
    }
    printf("\n");
}

int convertToCSR(int **matrix, int rows, int cols, CSR *csr) {
    *csr = (CSR){0};
    if (rows < 0 || cols < 0 || (rows > 0 && matrix == NULL) ||
        (size_t)rows >= SIZE_MAX / sizeof(int) ||
        (size_t)cols >= SIZE_MAX / sizeof(int) ||
        ((size_t)rows * (size_t)cols) > SIZE_MAX / sizeof(Element) ||
        (cols != 0 && rows > INT_MAX / cols)) return 0;
    for (int i = 0; i < rows; i++) {
        if (cols > 0 && matrix[i] == NULL) return 0;
    }
    int nonZeroCount = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (matrix[i][j] != 0) {
                nonZeroCount++;
            }
        }
    }
    csr->rows = rows;
    csr->cols = cols;
    csr->nonZeroCount = nonZeroCount;
    csr->values = nonZeroCount ? malloc((size_t)nonZeroCount * sizeof(int)) : NULL;
    csr->colIndex = nonZeroCount ? malloc((size_t)nonZeroCount * sizeof(int)) : NULL;
    csr->rowPtr = malloc(((size_t)rows + 1) * sizeof(int));
    if ((nonZeroCount && (!csr->values || !csr->colIndex)) || !csr->rowPtr) {
        free(csr->values);
        free(csr->colIndex);
        free(csr->rowPtr);
        *csr = (CSR){0};
        return 0;
    }
    int k = 0;
    csr->rowPtr[0] = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (matrix[i][j] != 0) {
                csr->values[k] = matrix[i][j];
                csr->colIndex[k] = j;
                k++;
            }
        }
        csr->rowPtr[i + 1] = k;
    }
    return 1;
}

int convertToCSC(int **matrix, int rows, int cols, CSC *csc) {
    *csc = (CSC){0};
    if (rows < 0 || cols < 0 || (rows > 0 && matrix == NULL) ||
        (size_t)rows >= SIZE_MAX / sizeof(int) ||
        (size_t)cols >= SIZE_MAX / sizeof(int) ||
        ((size_t)rows * (size_t)cols) > SIZE_MAX / sizeof(Element) ||
        (cols != 0 && rows > INT_MAX / cols)) return 0;
    for (int i = 0; i < rows; i++) {
        if (cols > 0 && matrix[i] == NULL) return 0;
    }
    int nonZeroCount = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (matrix[i][j] != 0) {
                nonZeroCount++;
            }
        }
    }
    csc->rows = rows;
    csc->cols = cols;
    csc->nonZeroCount = nonZeroCount;
    csc->values = nonZeroCount ? malloc((size_t)nonZeroCount * sizeof(int)) : NULL;
    csc->rowIndex = nonZeroCount ? malloc((size_t)nonZeroCount * sizeof(int)) : NULL;
    csc->colPtr = malloc(((size_t)cols + 1) * sizeof(int));
    if ((nonZeroCount && (!csc->values || !csc->rowIndex)) || !csc->colPtr) {
        free(csc->values);
        free(csc->rowIndex);
        free(csc->colPtr);
        *csc = (CSC){0};
        return 0;
    }
    int k = 0;
    csc->colPtr[0] = 0;
    for (int j = 0; j < cols; j++) {
        for (int i = 0; i < rows; i++) {
            if (matrix[i][j] != 0) {
                csc->values[k] = matrix[i][j];
                csc->rowIndex[k] = i;
                k++;
            }
        }
        csc->colPtr[j + 1] = k;
    }
    return 1;
}

int convertToCOO(int **matrix, int rows, int cols, COO *coo) {
    *coo = (COO){0};
    if (rows < 0 || cols < 0 || (rows > 0 && matrix == NULL) ||
        (size_t)rows >= SIZE_MAX / sizeof(int) ||
        (size_t)cols >= SIZE_MAX / sizeof(int) ||
        ((size_t)rows * (size_t)cols) > SIZE_MAX / sizeof(Element) ||
        (cols != 0 && rows > INT_MAX / cols)) return 0;
    for (int i = 0; i < rows; i++) {
        if (cols > 0 && matrix[i] == NULL) return 0;
    }
    int nonZeroCount = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (matrix[i][j] != 0) {
                nonZeroCount++;
            }
        }
    }
    coo->nonZeroCount = nonZeroCount;
    coo->elements = nonZeroCount ? malloc((size_t)nonZeroCount * sizeof(Element)) : NULL;
    if (nonZeroCount && !coo->elements) {
        *coo = (COO){0};
        return 0;
    }
    int k = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (matrix[i][j] != 0) {
                coo->elements[k].row = i;
                coo->elements[k].col = j;
                coo->elements[k].value = matrix[i][j];
                k++;
            }
        }
    }
    return 1;
}

int main(void) {
    int exampleMatrix[4][5] = {
        {0, 0, 3, 0, 4},
        {0, 0, 5, 7, 0},
        {0, 0, 0, 0, 0},
        {0, 2, 6, 0, 0}
    };
    int *matrix[4];
    for (int i = 0; i < 4; i++) matrix[i] = exampleMatrix[i];
    CSR csr = {0};
    CSC csc = {0};
    COO coo = {0};
    int success = convertToCSR(matrix, 4, 5, &csr) &&
                  convertToCSC(matrix, 4, 5, &csc) &&
                  convertToCOO(matrix, 4, 5, &coo);
    if (success) {
        printCSR(&csr);
        printCSC(&csc);
        printCOO(&coo);
    } else {
        fprintf(stderr, "Sparse matrix conversion failed.\n");
    }
    free(csr.values);
    free(csr.colIndex);
    free(csr.rowPtr);
    free(csc.values);
    free(csc.rowIndex);
    free(csc.colPtr);
    free(coo.elements);
    return success ? EXIT_SUCCESS : EXIT_FAILURE;
}
