//KERNEL STARTS AT 100000
#include "kernel.h"
#include "mylib.h"
#include "output.h"  //header files use "" not <>

void kmain(void) {
    draw_line(50, 50, 200, 50, 0x00FF0000);
    while (1) {
        ;
    }
}