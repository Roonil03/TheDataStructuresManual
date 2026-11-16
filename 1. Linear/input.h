#ifndef LINEAR_INPUT_H
#define LINEAR_INPUT_H

#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

/* Read one complete integer token; stop on EOF or malformed input. */
static int readInteger(int *value) {
    char token[64];
    size_t length = 0;
    int c;
    do {
        c = getchar();
    } while (c != EOF && isspace((unsigned char)c));
    if (c == EOF) return 0;
    int tooLong = 0;
    do {
        if (length + 1 < sizeof(token)) token[length++] = (char)c;
        else tooLong = 1;
        c = getchar();
    } while (c != EOF && !isspace((unsigned char)c));
    token[length] = '\0';
    char *end;
    errno = 0;
    long parsed = strtol(token, &end, 10);
    if (tooLong || end == token || errno == ERANGE || *end != '\0' || parsed < INT_MIN || parsed > INT_MAX) {
        fprintf(stderr, "Invalid integer input.\n");
        return 0;
    }
    *value = (int)parsed;
    return 1;
}

#endif
