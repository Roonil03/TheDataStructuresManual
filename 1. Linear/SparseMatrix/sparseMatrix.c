#include <stdio.h>
#include <stdlib.h>

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

void convertToCSR(int **matrix, int rows, int cols, CSR *csr) {
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
    csr->values = (int *)malloc(nonZeroCount * sizeof(int));
    csr->colIndex = (int *)malloc(nonZeroCount * sizeof(int));
    csr->rowPtr = (int *)malloc((rows + 1) * sizeof(int));
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
}

void convertToCSC(int **matrix, int rows, int cols, CSC *csc) {
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
    csc->values = (int *)malloc(nonZeroCount * sizeof(int));
    csc->rowIndex = (int *)malloc(nonZeroCount * sizeof(int));
    csc->colPtr = (int *)malloc((cols + 1) * sizeof(int));
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
}

void convertToCOO(int **matrix, int rows, int cols, COO *coo) {
    int nonZeroCount = 0;    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (matrix[i][j] != 0) {
                nonZeroCount++;
            }
        }
    }
    coo->nonZeroCount = nonZeroCount;
    coo->elements = (Element *)malloc(nonZeroCount * sizeof(Element));
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
}

int main() {
    int rows = 4, cols = 5;
    int **matrix = (int **)malloc(rows * sizeof(int *));
    for (int i = 0; i < rows; i++) {
        matrix[i] = (int *)malloc(cols * sizeof(int));
    }

    // Example sparse matrix
    int exampleMatrix[4][5] = {
        {0, 0, 3, 0, 4},
        {0, 0, 5, 7, 0},
        {0, 0, 0, 0, 0},
        {0, 2, 6, 0, 0}
    };

    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            matrix[i][j] = exampleMatrix[i][j];
        }
    }
    CSR csr;
    CSC csc;
    COO coo;
    convertToCSR(matrix, rows, cols, &csr);
    convertToCSC(matrix, rows, cols, &csc);
    convertToCOO(matrix, rows, cols, &coo);
    printCSR(&csr);
    printCSC(&csc);
    printCOO(&coo);
    free(csr.values);
    free(csr.colIndex);
    free(csr.rowPtr);
    free(csc.values);
    free(csc.rowIndex);
    free(csc.colPtr);
    free(coo.elements);
    for (int i = 0; i < rows; i++) {
        free(matrix[i]);
    }
    free(matrix);

    return 0;
}