module ivan.ifs3d.gl3;

//http://www.opengl.org/registry/api/gl3.h

string getMethodPointer(string name) {
	return "
    	gl3." ~ name ~ " = cast(typeof(gl3." ~ name ~ ")) glfwGetProcAddress(cast(char*) \"" ~ name ~ "\");
    	writefln(\"Function " ~ name ~ " %s\", gl3." ~ name ~ ");    
    ";
}

extern(System):

	alias uint GLenum;
	alias ubyte GLboolean;
	alias uint GLbitfield;
	alias byte GLbyte;
	alias short GLshort;
	alias int GLint;
	alias int GLsizei;
	alias ubyte GLubyte;
	alias ushort GLushort;
	alias uint GLuint;
	alias float GLfloat;
	alias float GLclampf;
	alias double GLdouble;
	alias double GLclampd;
	alias void GLvoid;

	/* AttribMask */
	const uint GL_DEPTH_BUFFER_BIT = 0x00000100;
	const uint GL_STENCIL_BUFFER_BIT = 0x00000400;
	const uint GL_COLOR_BUFFER_BIT = 0x00004000;
	/* Boolean */
	const uint GL_FALSE = 0;
	const uint GL_TRUE = 1;
	/* BeginMode */
	const uint GL_POINTS = 0x0000;
	const uint GL_LINES = 0x0001;
	const uint GL_LINE_LOOP = 0x0002;
	const uint GL_LINE_STRIP = 0x0003;
	const uint GL_TRIANGLES = 0x0004;
	const uint GL_TRIANGLE_STRIP = 0x0005;
	const uint GL_TRIANGLE_FAN = 0x0006;
	/* AlphaFunction */
	const uint GL_NEVER = 0x0200;
	const uint GL_LESS = 0x0201;
	const uint GL_EQUAL = 0x0202;
	const uint GL_LEQUAL = 0x0203;
	const uint GL_GREATER = 0x0204;
	const uint GL_NOTEQUAL = 0x0205;
	const uint GL_GEQUAL = 0x0206;
	const uint GL_ALWAYS = 0x0207;
	/* BlendingFactorDest */
	const uint GL_ZERO = 0;
	const uint GL_ONE = 1;
	const uint GL_SRC_COLOR = 0x0300;
	const uint GL_ONE_MINUS_SRC_COLOR = 0x0301;
	const uint GL_SRC_ALPHA = 0x0302;
	const uint GL_ONE_MINUS_SRC_ALPHA = 0x0303;
	const uint GL_DST_ALPHA = 0x0304;
	const uint GL_ONE_MINUS_DST_ALPHA = 0x0305;
	/* BlendingFactorSrc */
	const uint GL_DST_COLOR = 0x0306;
	const uint GL_ONE_MINUS_DST_COLOR = 0x0307;
	const uint GL_SRC_ALPHA_SATURATE = 0x0308;
	/* DrawBufferMode */
	const uint GL_NONE = 0;
	const uint GL_FRONT_LEFT = 0x0400;
	const uint GL_FRONT_RIGHT = 0x0401;
	const uint GL_BACK_LEFT = 0x0402;
	const uint GL_BACK_RIGHT = 0x0403;
	const uint GL_FRONT = 0x0404;
	const uint GL_BACK = 0x0405;
	const uint GL_LEFT = 0x0406;
	const uint GL_RIGHT = 0x0407;
	const uint GL_FRONT_AND_BACK = 0x0408;
	/* ErrorCode */
	const uint GL_NO_ERROR = 0;
	const uint GL_INVALID_ENUM = 0x0500;
	const uint GL_INVALID_VALUE = 0x0501;
	const uint GL_INVALID_OPERATION = 0x0502;
	const uint GL_OUT_OF_MEMORY = 0x0505;
	/* FrontFaceDirection */
	const uint GL_CW = 0x0900;
	const uint GL_CCW = 0x0901;
	/* GetPName */
	const uint GL_POINT_SIZE = 0x0B11;
	const uint GL_POINT_SIZE_RANGE = 0x0B12;
	const uint GL_POINT_SIZE_GRANULARITY = 0x0B13;
	const uint GL_LINE_SMOOTH = 0x0B20;
	const uint GL_LINE_WIDTH = 0x0B21;
	const uint GL_LINE_WIDTH_RANGE = 0x0B22;
	const uint GL_LINE_WIDTH_GRANULARITY = 0x0B23;
	const uint GL_POLYGON_SMOOTH = 0x0B41;
	const uint GL_CULL_FACE = 0x0B44;
	const uint GL_CULL_FACE_MODE = 0x0B45;
	const uint GL_FRONT_FACE = 0x0B46;
	const uint GL_DEPTH_RANGE = 0x0B70;
	const uint GL_DEPTH_TEST = 0x0B71;
	const uint GL_DEPTH_WRITEMASK = 0x0B72;
	const uint GL_DEPTH_CLEAR_VALUE = 0x0B73;
	const uint GL_DEPTH_FUNC = 0x0B74;
	const uint GL_STENCIL_TEST = 0x0B90;
	const uint GL_STENCIL_CLEAR_VALUE = 0x0B91;
	const uint GL_STENCIL_FUNC = 0x0B92;
	const uint GL_STENCIL_VALUE_MASK = 0x0B93;
	const uint GL_STENCIL_FAIL = 0x0B94;
	const uint GL_STENCIL_PASS_DEPTH_FAIL = 0x0B95;
	const uint GL_STENCIL_PASS_DEPTH_PASS = 0x0B96;
	const uint GL_STENCIL_REF = 0x0B97;
	const uint GL_STENCIL_WRITEMASK = 0x0B98;
	const uint GL_VIEWPORT = 0x0BA2;
	const uint GL_DITHER = 0x0BD0;
	const uint GL_BLEND_DST = 0x0BE0;
	const uint GL_BLEND_SRC = 0x0BE1;
	const uint GL_BLEND = 0x0BE2;
	const uint GL_LOGIC_OP_MODE = 0x0BF0;
	const uint GL_COLOR_LOGIC_OP = 0x0BF2;
	const uint GL_DRAW_BUFFER = 0x0C01;
	const uint GL_READ_BUFFER = 0x0C02;
	const uint GL_SCISSOR_BOX = 0x0C10;
	const uint GL_SCISSOR_TEST = 0x0C11;
	const uint GL_COLOR_CLEAR_VALUE = 0x0C22;
	const uint GL_COLOR_WRITEMASK = 0x0C23;
	const uint GL_DOUBLEBUFFER = 0x0C32;
	const uint GL_STEREO = 0x0C33;
	const uint GL_LINE_SMOOTH_HINT = 0x0C52;
	const uint GL_POLYGON_SMOOTH_HINT = 0x0C53;
	const uint GL_UNPACK_SWAP_BYTES = 0x0CF0;
	const uint GL_UNPACK_LSB_FIRST = 0x0CF1;
	const uint GL_UNPACK_ROW_LENGTH = 0x0CF2;
	const uint GL_UNPACK_SKIP_ROWS = 0x0CF3;
	const uint GL_UNPACK_SKIP_PIXELS = 0x0CF4;
	const uint GL_UNPACK_ALIGNMENT = 0x0CF5;
	const uint GL_PACK_SWAP_BYTES = 0x0D00;
	const uint GL_PACK_LSB_FIRST = 0x0D01;
	const uint GL_PACK_ROW_LENGTH = 0x0D02;
	const uint GL_PACK_SKIP_ROWS = 0x0D03;
	const uint GL_PACK_SKIP_PIXELS = 0x0D04;
	const uint GL_PACK_ALIGNMENT = 0x0D05;
	const uint GL_MAX_TEXTURE_SIZE = 0x0D33;
	const uint GL_MAX_VIEWPORT_DIMS = 0x0D3A;
	const uint GL_SUBPIXEL_BITS = 0x0D50;
	const uint GL_TEXTURE_1D = 0x0DE0;
	const uint GL_TEXTURE_2D = 0x0DE1;
	const uint GL_POLYGON_OFFSET_UNITS = 0x2A00;
	const uint GL_POLYGON_OFFSET_POINT = 0x2A01;
	const uint GL_POLYGON_OFFSET_LINE = 0x2A02;
	const uint GL_POLYGON_OFFSET_FILL = 0x8037;
	const uint GL_POLYGON_OFFSET_FACTOR = 0x8038;
	const uint GL_TEXTURE_BINDING_1D = 0x8068;
	const uint GL_TEXTURE_BINDING_2D = 0x8069;
	/* GetTextureParameter */
	const uint GL_TEXTURE_WIDTH = 0x1000;
	const uint GL_TEXTURE_HEIGHT = 0x1001;
	const uint GL_TEXTURE_INTERNAL_FORMAT = 0x1003;
	const uint GL_TEXTURE_BORDER_COLOR = 0x1004;
	const uint GL_TEXTURE_RED_SIZE = 0x805C;
	const uint GL_TEXTURE_GREEN_SIZE = 0x805D;
	const uint GL_TEXTURE_BLUE_SIZE = 0x805E;
	const uint GL_TEXTURE_ALPHA_SIZE = 0x805F;
	/* HintMode */
	const uint GL_DONT_CARE = 0x1100;
	const uint GL_FASTEST = 0x1101;
	const uint GL_NICEST = 0x1102;
	/* DataType */
	const uint GL_BYTE = 0x1400;
	const uint GL_UNSIGNED_BYTE = 0x1401;
	const uint GL_SHORT = 0x1402;
	const uint GL_UNSIGNED_SHORT = 0x1403;
	const uint GL_INT = 0x1404;
	const uint GL_UNSIGNED_INT = 0x1405;
	const uint GL_FLOAT = 0x1406;
	const uint GL_DOUBLE = 0x140A;
	/* LogicOp */
	const uint GL_CLEAR = 0x1500;
	const uint GL_AND = 0x1501;
	const uint GL_AND_REVERSE = 0x1502;
	const uint GL_COPY = 0x1503;
	const uint GL_AND_INVERTED = 0x1504;
	const uint GL_NOOP = 0x1505;
	const uint GL_XOR = 0x1506;
	const uint GL_OR = 0x1507;
	const uint GL_NOR = 0x1508;
	const uint GL_EQUIV = 0x1509;
	const uint GL_INVERT = 0x150A;
	const uint GL_OR_REVERSE = 0x150B;
	const uint GL_COPY_INVERTED = 0x150C;
	const uint GL_OR_INVERTED = 0x150D;
	const uint GL_NAND = 0x150E;
	const uint GL_SET = 0x150F;
	/* MatrixMode (for gl3.h, FBO attachment type) */
	const uint GL_TEXTURE = 0x1702;
	/* PixelCopyType */
	const uint GL_COLOR = 0x1800;
	const uint GL_DEPTH = 0x1801;
	const uint GL_STENCIL = 0x1802;
	/* PixelFormat */
	const uint GL_STENCIL_INDEX = 0x1901;
	const uint GL_DEPTH_COMPONENT = 0x1902;
	const uint GL_RED = 0x1903;
	const uint GL_GREEN = 0x1904;
	const uint GL_BLUE = 0x1905;
	const uint GL_ALPHA = 0x1906;
	const uint GL_RGB = 0x1907;
	const uint GL_RGBA = 0x1908;
	/* PolygonMode */
	const uint GL_POINT = 0x1B00;
	const uint GL_LINE = 0x1B01;
	const uint GL_FILL = 0x1B02;
	/* StencilOp */
	const uint GL_KEEP = 0x1E00;
	const uint GL_REPLACE = 0x1E01;
	const uint GL_INCR = 0x1E02;
	const uint GL_DECR = 0x1E03;
	/* StringName */
	const uint GL_VENDOR = 0x1F00;
	const uint GL_RENDERER = 0x1F01;
	const uint GL_VERSION = 0x1F02;
	const uint GL_EXTENSIONS = 0x1F03;
	/* TextureMagFilter */
	const uint GL_NEAREST = 0x2600;
	const uint GL_LINEAR = 0x2601;
	/* TextureMinFilter */
	const uint GL_NEAREST_MIPMAP_NEAREST = 0x2700;
	const uint GL_LINEAR_MIPMAP_NEAREST = 0x2701;
	const uint GL_NEAREST_MIPMAP_LINEAR = 0x2702;
	const uint GL_LINEAR_MIPMAP_LINEAR = 0x2703;
	/* TextureParameterName */
	const uint GL_TEXTURE_MAG_FILTER = 0x2800;
	const uint GL_TEXTURE_MIN_FILTER = 0x2801;
	const uint GL_TEXTURE_WRAP_S = 0x2802;
	const uint GL_TEXTURE_WRAP_T = 0x2803;
	/* TextureTarget */
	const uint GL_PROXY_TEXTURE_1D = 0x8063;
	const uint GL_PROXY_TEXTURE_2D = 0x8064;
	/* TextureWrapMode */
	const uint GL_REPEAT = 0x2901;
	/* PixelInternalFormat */
	const uint GL_R3_G3_B2 = 0x2A10;
	const uint GL_RGB4 = 0x804F;
	const uint GL_RGB5 = 0x8050;
	const uint GL_RGB8 = 0x8051;
	const uint GL_RGB10 = 0x8052;
	const uint GL_RGB12 = 0x8053;
	const uint GL_RGB16 = 0x8054;
	const uint GL_RGBA2 = 0x8055;
	const uint GL_RGBA4 = 0x8056;
	const uint GL_RGB5_A1 = 0x8057;
	const uint GL_RGBA8 = 0x8058;
	const uint GL_RGB10_A2 = 0x8059;
	const uint GL_RGBA12 = 0x805A;
	const uint GL_RGBA16 = 0x805B;

	//TODO nastaviti dalje...

	const uint GL_VERTEX_SHADER = 0x8B31;

	alias uint GLhandleARB;

	GLuint function(GLenum shaderType) glCreateShader;

	GLvoid function(GLuint shader, int numOfStrings, const char** strings, int* lenOfStrings)
			glShaderSource;