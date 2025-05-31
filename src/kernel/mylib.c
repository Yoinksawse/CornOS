#include "mylib.h"

//define shared constants

//define structures

//define functions
int abs(int x) {
    return x < 0 ? -x : x;
}

void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}