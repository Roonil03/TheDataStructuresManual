# Sparse Matrix:
A sparse matrix is a matrix in which most of the elements are zero. The opposite of a sparse matrix is a dense matrix, where most of the elements are non-zero. Sparse matrices often arise in scientific and engineering applications, such as simulations, optimizations, and machine learning, where the data is inherently sparse.

### Characteristics of Sparse Matrices
1. High Proportion of Zeros: Sparse matrices have a significant number of zero elements compared to non-zero elements.
2. Efficient Storage: Due to the large number of zeros, storing a sparse matrix in a traditional 2D array format can be highly inefficient in terms of memory. Special storage techniques are used to save space.
### Storage Formats for Sparse Matrices
To efficiently store and manipulate sparse matrices, several storage formats are used:

1. Compressed Sparse Row (CSR) Format:

    - Description: Stores only the non-zero elements and their row indices, along with pointers to the start of each row.
    - Components:
        - values: Array of non-zero elements.
        - column_indices: Array of column indices corresponding to each non-zero element.
        - row_pointer: Array where each entry points to the beginning of a row in the values array.
    - Use Case: Efficient for matrix-vector multiplication.
2. Compressed Sparse Column (CSC) Format:

    - Description: Similar to CSR but organized by columns instead of rows.
    - Components:
        - values: Array of non-zero elements.
        - row_indices: Array of row indices corresponding to each non-zero element.
        - column_pointer: Array where each entry points to the beginning of a column in the values array.
    - Use Case: Efficient for column-based operations.
3. Coordinate List (COO) Format:

    - Description: Stores a list of tuples representing the row index, column index, and value of each non-zero element.
    - Components:
        - row: Array of row indices.
        - col: Array of column indices.
        - data: Array of non-zero elements.
    - Use Case: Simple and easy to construct, useful for initializing sparse matrices.

    