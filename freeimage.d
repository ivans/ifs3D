module freeimage;


typedef void* fi_handle;
typedef uint function(void *buffer, uint size, uint count, fi_handle handle) FI_ReadProc;
typedef uint function(void *buffer, uint size, uint count, fi_handle handle) FI_WriteProc;
typedef int function(fi_handle handle, long offset, int origin) FI_SeekProc;
typedef long function(fi_handle handle) FI_TellProc;

alias int BOOL;
alias byte BYTE;
alias ubyte UBYTE;
typedef void* FIBITMAP;


struct FreeImageIO
{
	FI_ReadProc  read_proc;     // pointer to the function used to read data
    FI_WriteProc write_proc;    // pointer to the function used to write data
    FI_SeekProc  seek_proc;     // pointer to the function used to seek
    FI_TellProc  tell_proc;     // pointer to the function used to aquire the current position
};

struct RGBQUAD 
{
  UBYTE rgbBlue; 
  UBYTE rgbGreen; 
  UBYTE rgbRed; 
  UBYTE rgbReserved; 
} 

const int BMP_DEFAULT  =       0;
const int BMP_SAVE_RLE  =      1;
const int CUT_DEFAULT     =    0;
const int DDS_DEFAULT	=		0;
const int ICO_DEFAULT     =    0;
const int IFF_DEFAULT      =   0;
const int JPEG_DEFAULT   =     0;
const int JPEG_FAST       =    1;
const int JPEG_ACCURATE =      2;
const int JPEG_QUALITYSUPERB  = 0x80;
const int JPEG_QUALITYGOOD  =  0x100;
const int JPEG_QUALITYNORMAL=  0x200;
const int JPEG_QUALITYAVERAGE= 0x400;
const int JPEG_QUALITYBAD   =  0x800;
const int KOALA_DEFAULT  =     0;
const int LBM_DEFAULT    =     0;
const int MNG_DEFAULT   =      0;
const int PCD_DEFAULT   =      0;
const int PCD_BASE      =      1;		// load the bitmap sized 768 x 512
const int PCD_BASEDIV4   =     2;		// load the bitmap sized 384 x 256
const int PCD_BASEDIV16  =     3;		// load the bitmap sized 192 x 128
const int PCX_DEFAULT   =      0;
const int PNG_DEFAULT   =      0;
const int PNG_IGNOREGAMMA		=1;		// avoid gamma correction
const int PNM_DEFAULT  =       0;
const int PNM_SAVE_RAW   =     0;       // If set the writer saves in RAW format (i.e. P4, P5 or P6)
const int PNM_SAVE_ASCII   =   1;       // If set the writer saves in ASCII format (i.e. P1, P2 or P3)
const int PSD_DEFAULT   =     0;
const int RAS_DEFAULT    =     0;
const int TARGA_DEFAULT  =     0;
const int TARGA_LOAD_RGB888  = 1;       // If set the loader converts RGB555 and ARGB8888 -> RGB888.
const int TIFF_DEFAULT =       0;
const int TIFF_CMYK	=		0x0001;	// reads/stores tags for separated CMYK (use | to combine with compression flags)
const int TIFF_PACKBITS   =    0x0100;  // save using PACKBITS compression
const int TIFF_DEFLATE   =     0x0200;  // save using DEFLATE compression
const int TIFF_ADOBE_DEFLATE = 0x0400;  // save using ADOBE DEFLATE compression
const int TIFF_NONE       =    0x0800;  // save without any compression
const int WBMP_DEFAULT   =     0;
const int XBM_DEFAULT		=	0;
const int XPM_DEFAULT	=		0;

enum FREE_IMAGE_TYPE 
{
	FIT_UNKNOWN = 0,	// unknown type
	FIT_BITMAP  = 1,	// standard image			: 1-, 4-, 8-, 16-, 24-, 32-bit
	FIT_UINT16	= 2,	// array of unsigned short	: unsigned 16-bit
	FIT_INT16	= 3,	// array of short			: signed 16-bit
	FIT_UINT32	= 4,	// array of unsigned long	: unsigned 32-bit
	FIT_INT32	= 5,	// array of long			: signed 32-bit
	FIT_FLOAT	= 6,	// array of float			: 32-bit IEEE floating point
	FIT_DOUBLE	= 7,	// array of double			: 64-bit IEEE floating point
	FIT_COMPLEX	= 8		// array of FICOMPLEX		: 2 x 64-bit IEEE floating point
};

enum FREE_IMAGE_FORMAT
{
	FIF_UNKNOWN = -1,	FIF_BMP		= 0,	FIF_ICO		= 1,		FIF_JPEG	= 2,
	FIF_JNG		= 3,		FIF_KOALA	= 4,	FIF_LBM		= 5,		FIF_IFF = FIF_LBM,
	FIF_MNG		= 6,	FIF_PBM		= 7,	FIF_PBMRAW	= 8,	FIF_PCD		= 9,
	FIF_PCX		= 10,		FIF_PGM		= 11,	FIF_PGMRAW	= 12,	FIF_PNG		= 13,
	FIF_PPM		= 14,		FIF_PPMRAW	= 15,	FIF_RAS		= 16,	FIF_TARGA	= 17,
	FIF_TIFF	= 18,	FIF_WBMP	= 19,	FIF_PSD		= 20,	FIF_CUT		= 21,	FIF_XBM		= 22,
	FIF_XPM		= 23,	FIF_DDS		= 24
}

enum FREE_IMAGE_FILTER
{
	FILTER_BOX        = 0,	// Box, pulse, Fourier window, 1st order (constant) b-spline
	FILTER_BICUBIC	  = 1,	// Mitchell & Netravali's two-param cubic filter
	FILTER_BILINEAR   = 2,	// Bilinear filter
	FILTER_BSPLINE	  = 3,	// 4th order (cubic) b-spline
	FILTER_CATMULLROM = 4,	// Catmull-Rom spline, Overhauser spline
	FILTER_LANCZOS3	  = 5	 // Lanczos3 filter
}




alias void function (FREE_IMAGE_FORMAT fif, char *msg) FreeImage_OutputMessageFunction;

extern(Windows)
{
	//GENERAL FUNCTIONS
	void FreeImage_Initialise(BOOL load_local_plugins_only=false);	
	void FreeImage_DeInitialise();
	char* FreeImage_GetVersion();
	char *FreeImage_GetCopyrightMessage();
	void FreeImage_SetOutputMessage(FreeImage_OutputMessageFunction omf);
	BOOL FreeImage_IsLittleEndian();
	//BITMAP MANAGEMENT FUNCTIONS
	FIBITMAP* FreeImage_Allocate(int width, int height, int bpp, uint red_mask=0, uint green_mask=0, uint blue_mask=0);
	FIBITMAP* FreeImage_AllocateT(FREE_IMAGE_TYPE type, int width, int height, int bpp=8, uint red_mask=0, uint green_mask=0, uint blue_mask=0);
	FIBITMAP* FreeImage_Load(FREE_IMAGE_FORMAT fif, char *filename, int flags=0);
	BOOL FreeImage_Save(FREE_IMAGE_FORMAT fif, FIBITMAP*dib, char *filename, int flags =0);
	BOOL FreeImage_SaveToHandle(FREE_IMAGE_FORMAT fif, FIBITMAP* dib, FreeImageIO* io, fi_handle handle, int flags=0);
	FIBITMAP* FreeImage_Clone(FIBITMAP *dib);
	void FreeImage_Unload(FIBITMAP *dib);
	FREE_IMAGE_TYPE FreeImage_GetImageType(FIBITMAP *dib);
	uint FreeImage_GetColorsUsed(FIBITMAP *dib);
	uint FreeImage_GetBPP(FIBITMAP *dib);
	BOOL FreeImage_SetPixelColor(FIBITMAP *dib, uint x, uint y, RGBQUAD *value);
	BOOL FreeImage_GetPixelColor(FIBITMAP *dib, uint x, uint y, RGBQUAD *value);
  FIBITMAP* FreeImage_Rescale(FIBITMAP *dib, int dst_width, int dst_height, FREE_IMAGE_FILTER filter);
  FIBITMAP* FreeImage_ConvertTo32Bits(FIBITMAP *dib);
  FIBITMAP* FreeImage_ConvertTo24Bits(FIBITMAP *dib);

  BOOL FreeImage_AdjustGamma(FIBITMAP *dib, double gamma);
  BOOL FreeImage_AdjustBrightness(FIBITMAP *dib, double percentage);
  BOOL FreeImage_AdjustContrast(FIBITMAP *dib, double percentage);

}

