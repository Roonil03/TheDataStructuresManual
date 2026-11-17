#ifndef DATA_STRUCTURES_INPUT_H
#define DATA_STRUCTURES_INPUT_H

#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

/* Read one complete integer token; stop on EOF or malformed input. */
static inline int readInteger(int *value) {
    int c;
    do {
        c = getchar();
    } while (c != EOF && isspace((unsigned char)c));
    if (c == EOF) return 0;
    int negative = c == '-';
    if (c == '+' || c == '-') c = getchar();
    unsigned int magnitude = 0;
    unsigned int limit = negative ? (unsigned int)(-(INT_MIN + 1)) + 1U : (unsigned int)INT_MAX;
    int valid = 1, digits = 0;
    /* Accumulate the value, not the token, so leading zeroes need no buffer. */
    while (c != EOF && !isspace((unsigned char)c)) {
        if (c < '0' || c > '9') {
            valid = 0;
        } else {
            unsigned int digit = (unsigned int)(c - '0');
            digits = 1;
            if (magnitude > (limit - digit) / 10U) valid = 0;
            else magnitude = magnitude * 10U + digit;
        }
        c = getchar();
    }
    if (ferror(stdin)) valid = 0;
    if (!valid || !digits) {
        fprintf(stderr, "Invalid integer input.\n");
        return 0;
    }
    *value = negative ? (magnitude == limit ? INT_MIN : -(int)magnitude) : (int)magnitude;
    return 1;
}

/* Consume a whole token, rejecting truncation and embedded NUL bytes. */
static inline int readToken(char *token, size_t capacity) {
    int c;
    do {
        c = getchar();
    } while (c != EOF && isspace((unsigned char)c));
    if (c == EOF) return 0;
    size_t length = 0;
    int valid = capacity > 0;
    do {
        if (c == '\0') valid = 0;
        if (length + 1 < capacity) token[length++] = (char)c;
        else valid = 0;
        c = getchar();
    } while (c != EOF && !isspace((unsigned char)c));
    if (capacity > 0) token[length] = '\0';
    if (ferror(stdin)) valid = 0;
    if (!valid) {
        fprintf(stderr, "Invalid input token.\n");
        return 0;
    }
    return 1;
}

/* Read a complete, finite floating-point token for the rectangle demo. */
static inline int readDouble(double *value) {
    char token[128];
    if (!readToken(token, sizeof token)) return 0;
    char *end;
    errno = 0;
    double parsed = strtod(token, &end);
    if (end == token || *end != '\0' || errno == ERANGE || !isfinite(parsed)) {
        fprintf(stderr, "Invalid floating-point input.\n");
        return 0;
    }
    *value = parsed;
    return 1;
}

#endif
