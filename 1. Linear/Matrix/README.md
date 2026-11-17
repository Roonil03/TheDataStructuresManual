# Matrix:
A matrix is a two-dimensional array of numbers arranged in rows and columns. It can be represented as a rectangular grid of numbers or symbols, typically enclosed within brackets. Each element in a matrix is identified by two indices: the row number and the column number.

### Common Operations on Matrices
1. Addition and Subtraction: Combining or subtracting corresponding elements of two matrices.
    - Time Complexity: O(m * n), where m is the number of rows and n is the number of columns.
2. Multiplication: Performing matrix multiplication to combine two matrices.
    - Time Complexity: O(m * n * p), where m, n, and p are dimensions of the matrices.
3. Transpose: Flipping a matrix over its diagonal, turning rows into columns and vice versa.
    - Time Complexity: O(m * n)
4. Determinant: Calculating a scalar value that can determine certain properties of a square matrix.
    - Time Complexity: O(n^3) for an n x n matrix using Gaussian elimination.
5. Inverse: Finding a matrix that, when multiplied by the original matrix, yields the identity matrix.
    - Time Complexity: O(n^3) for an n x n matrix using Gaussian elimination.

### Examples in this directory

`matrix.c` reads and displays a 5×5 matrix of signed C `int` values. Input is whitespace-separated; missing or malformed input stops the program. `matrix.asm` is a Linux x86-64 NASM example that initializes a 5×5 matrix with 1 through 25 and prints its rows. These examples demonstrate storage and traversal; the arithmetic operations described above are not implemented here.
