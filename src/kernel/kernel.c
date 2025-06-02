//KERNEL STARTS AT 100000
#include "kernel.h"
#include "mylib.h"
#include "output.h"  //header files use "" not <>

void fill_screen_green() {
    vbeinfo_struct* vbeinfo = (vbeinfo_struct*)VBE_MODE_INFO_BLOCK_ADDR;
    uint8_t* vram = (uint8_t*)(uintptr_t)vbeinfo->framebuffer;

    if (vbeinfo->bpp != 32) return;

    uint32_t green_color = 0x00FF00FF;
    uint32_t width = vbeinfo->width;
    uint32_t height = vbeinfo->height;
    uint32_t pitch = vbeinfo->pitch;

    //write 1 row first
    uint32_t* row = (uint32_t*)vram;
    for (uint32_t x = 0; x < width; x++) row[x] = green_color;
    //copy row height times
    for (uint32_t y = 1; y < height; y++) {
        memcpy(vram + y * pitch, vram, width * 4);  //4bpp
    }
}

void kmain(void) {
    fill_screen_green();  // Optional
    while (1);
}