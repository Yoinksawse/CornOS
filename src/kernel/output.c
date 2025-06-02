#include <stdint.h>
#include "mylib.h"
#include "output.h" //header files use "" not <>

void put_pixel(int x, int y, uint32_t colour) {
    vbeinfo_struct* vbeinfo = (vbeinfo_struct*)VBE_MODE_INFO_BLOCK_ADDR;  //pointer to vbe info block
    uint8_t* buffer = (uint8_t*)(uintptr_t)vbeinfo->framebuffer;       //pointer to framebuffer address

    if (x < 0 || y < 0 || x >= vbeinfo->width || y >= vbeinfo->height) return;  // Check bounds

    // Calculate pixel offset based on actual BPP
    uint32_t pixel_offset = y * vbeinfo->pitch + x * (vbeinfo->bpp / 8);
    
	if (vbeinfo->bpp == 32) {
        uintptr_t pixel_addr = (uintptr_t)buffer + pixel_offset;
        *((uint32_t*)pixel_addr) = colour;
    } else if (vbeinfo->bpp == 24) {
        buffer[pixel_offset]     = (colour >> 0) & 0xFF;  //blue
        buffer[pixel_offset + 1] = (colour >> 8) & 0xFF;  //green
        buffer[pixel_offset + 2] = (colour >> 16) & 0xFF; //red
    }
}

/*
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
*/


/*
//bresenham
void draw_line(int sx, int sy, int ex, int ey, uint32_t colour) {
	if (abs(ex - sx) > abs(ey - sy)) draw_horizontal_line(sx, sy, ex, ey, colour);
	else draw_vertical_line(sx, sy, ex, ey, colour);
}

void draw_horizontal_line(int sx, int sy, int ex, int ey, uint32_t colour) {
	if (sx > ex) swap(&sx, &ex), swap(&sy, &ey); //cover all horizontal lines

	int dx = ex - sx; //change in x
    int dy = ey - sy; //change in y
	
	short upordown = (dy < 0) ? -1 : 1; //consider negative dy (up direction)
	dy *= upordown;
	
	if (dx != 0) {
		int cury = sy;
		int p0 = 2*dy - dx;
		for (int curx = sx; curx <= ex; curx++) {		//need to optimise using asm rep (for put pixel)
			put_pixel(curx, cury, colour);
			if (p0 > 0) {
				cury += upordown;
				p0 -= 2*dx; //if changed
			}
			p0 = p0 + 2*dy; //if unchanged
		}
	}
}

void draw_vertical_line(int sx, int sy, int ex, int ey, uint32_t colour) {
	if (sy > ey) swap(&sx, &ex), swap(&sy, &ey); //cover all horizontal lines

	int dx = ex - sx; //change in x
    int dy = ey - sy; //change in y

	
	short upordown = (dx < 0) ? -1 : 1; //consider negative dy (up direction)
	dx *= upordown;
	
	if (dy != 0) {
		int curx = sx;
		int p0 = 2*dx - dy;
		for (int cury = sy; cury <= ey; cury++) {		//need to optimise using asm rep (for put pixel)
			put_pixel(curx, cury, colour);	//?
			if (p0 > 0) {
				curx += upordown;
				p0 -= 2*dy; //if changed
			}
			p0 = p0 + 2*dx; //if unchanged
		}
	}
}

*/