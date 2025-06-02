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

void memcpy(void *dest, void *src, unsigned int n) {  //from gfg
// Typecast src and dest addresses to (char *) 
char *csrc = (char *)src; 
char *cdest = (char *)dest; 

// Copy contents of src[] to dest[] 
for (int i=0; i<n; i++) 
    cdest[i] = csrc[i]; 
} 