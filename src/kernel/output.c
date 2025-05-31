#include <stdint.h>
#include "mylib.h"
#include "output.h" //header files use "" not <>

void put_pixel(int x, int y, unsigned char colour) {
	//pointer to vbe info block
	vbeinfo_struct* vbeinfo = (vbeinfo_struct*) VBE_INFO_BLOCK_ADDR;
	//pointer to framebuffer address
	uint8_t* vram = (uint8_t*)(uintptr_t) vbeinfo->framebuffer;

	//pointer to pixel to place (address in video ram)
	//bpp:pixel width (x), pitch: y (formula for pixel offset)
	uint32_t *pixel = (uint32_t*)(vram + y * (vbeinfo->pitch) + x * (vbeinfo->bpp / 8));
	
	//PUT!!!!!
	//32 bit/doubleword per pixel => ARGB colour: dd 0x00RRGGBB
	*pixel = colour;
}

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