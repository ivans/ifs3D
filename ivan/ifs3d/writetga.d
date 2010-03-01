module ivan.ifs3d.writetga;

import std.c.stdio, std.stdio;
import std.c.stdlib;
import glfw;
import freeimage;

struct TGAHEADER {
	align(1):
		GLbyte identsize; // Size of ID field that follows header (0)
		GLbyte colorMapType; // 0 = None, 1 = paletted
		GLbyte imageType; // 0 = none, 1 = indexed, 2 = rgb, 3 = grey, +8=rle
		ushort colorMapStart; // First colour map entry
		ushort colorMapLength; // Number of colors
		ubyte colorMapBits; // bits per palette entry
		ushort xstart; // image x origin
		ushort ystart; // image y origin
		ushort width; // width in pixels
		ushort height; // height in pixels
		GLbyte bits; // bits per pixel (8 16, 24, 32)
		GLbyte descriptor; // image descriptor
}

GLint gltWriteTGA(char* szFileName) {
	FILE* pFile; // File pointer
	TGAHEADER tgaHeader; // TGA file header
	uint lImageSize; // Size in bytes of image
	GLbyte* pBits = null; // Pointer to bits
	GLint iViewport[4]; // Viewport in pixels
	GLenum lastBuffer; // Storage for the current read buffer setting

	// Get the viewport dimensions
	glGetIntegerv(GL_VIEWPORT, iViewport.ptr);

	// How big is the image going to be (targas are tightly packed)
	lImageSize = iViewport[2] * 3 * iViewport[3];

	// Allocate block. If this doesn't work, go home
	pBits = cast(GLbyte*) malloc(lImageSize);
	if(pBits == cast(byte*) 0)
		return 0;

	// Read bits from color buffer
	glPixelStorei(GL_PACK_ALIGNMENT, 1);
	glPixelStorei(GL_PACK_ROW_LENGTH, 0);
	glPixelStorei(GL_PACK_SKIP_ROWS, 0);
	glPixelStorei(GL_PACK_SKIP_PIXELS, 0);

	// Get the current read buffer setting and save it. Switch to
	// the front buffer and do the read operation. Finally, restore
	// the read buffer state
	glGetIntegerv(GL_READ_BUFFER, cast(int*) &lastBuffer);
	glReadBuffer(GL_FRONT);
	glReadPixels(0, 0, iViewport[2], iViewport[3], GL_BGR_EXT,
			GL_UNSIGNED_BYTE, pBits);
	glReadBuffer(lastBuffer);

	// Initialize the Targa header
	tgaHeader.identsize = 0;
	tgaHeader.colorMapType = 0;
	tgaHeader.imageType = 2;
	tgaHeader.colorMapStart = 0;
	tgaHeader.colorMapLength = 0;
	tgaHeader.colorMapBits = 0;
	tgaHeader.xstart = 0;
	tgaHeader.ystart = 0;
	tgaHeader.width = cast(ushort) iViewport[2];
	tgaHeader.height = cast(ushort) iViewport[3];
	tgaHeader.bits = 24;
	tgaHeader.descriptor = 0;

	// Attempt to open the file
	pFile = fopen(szFileName, "wb");
	if(cast(int) pFile == 0) {
		free(pBits); // Free buffer and return error
		return 0;
	}

	// Write the header
	fwrite(&tgaHeader, TGAHEADER.sizeof, 1, pFile);

	// Write the image data
	fwrite(pBits, lImageSize, 1, pFile);

	// Free temporary buffer and close the file
	free(pBits);
	fclose(pFile);

	// Success!
	return 1;
}

RGBQUAD thePixel;

RGBQUAD* getColor(ubyte r, ubyte g, ubyte b) {
	thePixel.rgbBlue = r;
	thePixel.rgbGreen = g;
	thePixel.rgbRed = b;
	return &thePixel;
}

RGBQUAD* getColor(float r, float g, float b) {
	thePixel.rgbBlue = cast(ubyte) (r * 255);
	thePixel.rgbGreen = cast(ubyte) (g * 255);
	thePixel.rgbRed = cast(ubyte) (b * 255);
	return &thePixel;
}

GLint writeJpeg(string fileName) {
	uint lImageSize; // Size in bytes of image
	ubyte[] pBits; // Pointer to bits
	GLint iViewport[4]; // Viewport in pixels
	GLenum lastBuffer; // Storage for the current read buffer setting

	// Get the viewport dimensions
	glGetIntegerv(GL_VIEWPORT, iViewport.ptr);

	lImageSize = iViewport[2] * 3 * iViewport[3];

	//	debug
	//		writefln("Image size: %s x %s", iViewport[2], iViewport[3]);
	FIBITMAP* thePicture = FreeImage_Allocate(iViewport[2], iViewport[3], 24);

	pBits.length = lImageSize;

	glPixelStorei(GL_PACK_ALIGNMENT, 1);
	glPixelStorei(GL_PACK_ROW_LENGTH, iViewport[2]);
	glPixelStorei(GL_PACK_SKIP_ROWS, 0);
	glPixelStorei(GL_PACK_SKIP_PIXELS, 0);

	glGetIntegerv(GL_READ_BUFFER, cast(int*) &lastBuffer);
	glReadBuffer(GL_FRONT);
	glReadPixels(0, 0, iViewport[2], iViewport[3], GL_BGR_EXT,
			GL_UNSIGNED_BYTE, pBits.ptr);
	glReadBuffer(lastBuffer);

	for(uint y = 0; y < iViewport[3]; y++) {
		for(uint x = 0; x < iViewport[2]; x++) {
			FreeImage_SetPixelColor(thePicture, x, y,
					cast(RGBQUAD*) &pBits[x * 3 + 3 * y * iViewport[2]]);
		}
	}

	FreeImage_Save(FREE_IMAGE_FORMAT.FIF_JPEG, thePicture,
			cast(char*) (fileName ~ "\0"), JPEG_QUALITYSUPERB);

	FreeImage_Unload(thePicture);

	return 1;
}
