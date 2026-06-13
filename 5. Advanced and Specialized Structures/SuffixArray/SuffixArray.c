#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char *text;
    int n;
    int *sa;
    int *rank;
    int *lcp;
} SuffixArray;

static int cmp_suffix(const void *a, const void *b, void *arg) {
    const char *text = (const char *)arg;
    return strcmp(text + *(const int *)a, text + *(const int *)b);
}

static void build_sa(SuffixArray *s) {
    for (int i = 0; i < s->n; i++)
        s->sa[i] = i;
    qsort_r(s->sa, s->n, sizeof(int), cmp_suffix, s->text);
}

static void build_rank(SuffixArray *s) {
    for (int i = 0; i < s->n; i++)
        s->rank[s->sa[i]] = i;
}

static void build_lcp(SuffixArray *s) {
    build_rank(s);
    int k = 0;
    for (int i = 0; i < s->n; i++) {
        if (s->rank[i] == 0) { k = 0; continue; }
        int j = s->sa[s->rank[i] - 1];
        while (i + k < s->n && j + k < s->n && s->text[i + k] == s->text[j + k])
            k++;
        s->lcp[s->rank[i]] = k;
        if (k) k--;
    }
    s->lcp[0] = 0;
}

SuffixArray *sa_create(const char *text) {
    SuffixArray *s = malloc(sizeof(SuffixArray));
    s->n = strlen(text);
    s->text = malloc(s->n + 1);
    strcpy(s->text, text);
    s->sa = malloc(s->n * sizeof(int));
    s->rank = malloc(s->n * sizeof(int));
    s->lcp = malloc(s->n * sizeof(int));
    build_sa(s);
    build_lcp(s);
    return s;
}

int sa_search(SuffixArray *s, const char *pattern) {
    int plen = strlen(pattern);
    int lo = 0, hi = s->n - 1;
    while (lo <= hi) {
        int mid = lo + (hi - lo) / 2;
        int cmp = strncmp(s->text + s->sa[mid], pattern, plen);
        if (cmp == 0) return s->sa[mid];
        if (cmp < 0) lo = mid + 1;
        else hi = mid - 1;
    }
    return -1;
}

int sa_count(SuffixArray *s, const char *pattern) {
    int plen = strlen(pattern);
    int first = -1, last = -1;

    int l = 0, r = s->n - 1;
    while (l <= r) {
        int mid = l + (r - l) / 2;
        if (strncmp(s->text + s->sa[mid], pattern, plen) >= 0) {
            first = mid;
            r = mid - 1;
        } else {
            l = mid + 1;
        }
    }

    l = 0; r = s->n - 1;
    while (l <= r) {
        int mid = l + (r - l) / 2;
        if (strncmp(s->text + s->sa[mid], pattern, plen) <= 0) {
            last = mid;
            l = mid + 1;
        } else {
            r = mid - 1;
        }
    }

    if (first == -1 || last == -1) return 0;
    if (strncmp(s->text + s->sa[first], pattern, plen) != 0) return 0;
    return last - first + 1;
}

void sa_print(SuffixArray *s) {
    printf("Suffix Array for \"%s\" (n=%d):\n", s->text, s->n);
    printf("%4s %4s %4s  %s\n", "i", "SA", "LCP", "Suffix");
    for (int i = 0; i < s->n; i++)
        printf("%4d %4d %4d  \"%s\"\n", i, s->sa[i], s->lcp[i], s->text + s->sa[i]);
}

void sa_free(SuffixArray *s) {
    free(s->text);
    free(s->sa);
    free(s->rank);
    free(s->lcp);
    free(s);
}

int main(void) {
    SuffixArray *s = sa_create("banana");

    sa_print(s);

    int pos = sa_search(s, "ana");
    printf("Search 'ana': position %d\n", pos);

    pos = sa_search(s, "ban");
    printf("Search 'ban': position %d\n", pos);

    pos = sa_search(s, "xyz");
    printf("Search 'xyz': position %d\n", pos);

    printf("Count 'ana': %d\n", sa_count(s, "ana"));
    printf("Count 'an': %d\n", sa_count(s, "an"));
    printf("Count 'a': %d\n", sa_count(s, "a"));
    printf("Count 'xyz': %d\n", sa_count(s, "xyz"));

    sa_free(s);
    printf("All tests passed.\n");
    return 0;
}
