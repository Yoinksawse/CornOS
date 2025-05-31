#include <stdint.h>

struct vbe_mode_info_structure {
	uint16_t attributes;		    // only bit 7 useful: indicates the mode supports linear framebuffer
	uint8_t window_a;			    // USELESS (deprecated)
	uint8_t window_b;			    // USELESS (deprecated)
	uint16_t granularity;		    // USELESS (deprecated)
	uint16_t window_size;
	uint16_t segment_a;
	uint16_t segment_b;
	uint32_t win_func_ptr;		    // USELESS (deprecated)
	uint16_t pitch;			        // number of bytes per horizontal line
	uint16_t width;			        // width (px)
	uint16_t height;			    // height (px)
	uint8_t w_char;			        // USELESS (unused)
	uint8_t y_char;			        // USELESS (unused)
	uint8_t planes;
	uint8_t bpp;			        // bits per pixel in this mode
	uint8_t banks;			        // USELESS (deprecated)
	uint8_t memory_model;
	uint8_t bank_size;		        // USELESS (deprecated)
	uint8_t image_pages;
	uint8_t reserved0;

	uint8_t red_mask;
	uint8_t red_position;
	uint8_t green_mask;
	uint8_t green_position;
	uint8_t blue_mask;
	uint8_t blue_position;
	uint8_t reserved_mask;
	uint8_t reserved_position;
	uint8_t direct_color_attributes;

	uint32_t framebuffer;		    // physical address of linear framebuffer; write here to draw to the screen
	uint32_t off_screen_mem_off;
	uint16_t off_screen_mem_size;	// size of memory in the framebuffer but not being displayed on the screen
	uint8_t reserved1[206];
} __attribute__ ((packed));

volatile struct vbe_mode_info_structure* vbe_info = (volatile struct vbe_mode_info_structure*)0x8000;

void put_pixel(int x, int y, unsigned char colour) {
	uint8_t* vram = (uint8_t*)(uintptr_t) vbe_info->framebuffer;						//framebuffer pos
	unsigned char *pixel = vram + y * (vbe_info->pitch) + x * (vbe_info->bpp / 8);		//bpp:pixel width (x), pitch: y
	*pixel = colour;
}