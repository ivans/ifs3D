module ivan.ifs3d.config;

private {
	import std.stream, std.string;
	import std.file;
	import std.conv;
	import std.stdio;

	import ivan.ifs3d.callback;
	import ivan.ifs3d.global;

	alias ivan.ifs3d.global global;

	import gl3 = ivan.ifs3d.gl3;
	import glfw;
	import freeimage;
}

class Config {
	this(string fileName) {
		intParams["fileCounter"] = 0;
		intParams["iterationsWhenSaving"] = 10000;
		intParams["depthBits"] = 32;
		intParams["drawTransAndAxes"] = 1;
		intParams["resX"] = 800;
		intParams["resY"] = 600;
		intParams["picResX"] = 1024 * 2;
		intParams["picResY"] = 768 * 2;
		intParams["picSmallX"] = 1024;
		intParams["picSmallY"] = 768;

		if(std.file.exists(fileName)) {
			debug
				global.o.writefln("Config file found, loading...");
			loadConfigFile(fileName);
		} else {
			debug
				global.o.writefln("Config file not found, creating...");
			saveConfigFile(fileName);
		}

		intParams["adjContrast"] = 0;
		intParams["adjBrightness"] = 0;
		intParams["adjGamma"] = -80;
	}

	void saveConfigFile(string fileName) {
		debug
			writeln("Saving config file to ", fileName);
		std.stream.File f = new std.stream.File(fileName, FileMode.OutNew);
		printParams(f);
		f.close();
		return;
	}

	void loadConfigFile(string fileName) {
		debug
			writeln("Loading config file from ", fileName);
		char[] key;
		char[] value;
		std.stream.File f = new std.stream.File(fileName, FileMode.In);
		while(f.readf(&key, &value) != 0) {
			intParams[key.dup] = std.conv.to!(int)(value);
		}
		printParams(global.o);
		f.close();
		return;
	}

	void printParams(Stream s) {
		foreach(key, value; intParams) {
			if(key != "") {
				s.writefln("%s %d", key, value);
			}
		}
	}

	void clrscr() {
		clearscreen = 2;
	}

	void InitFreeImage() {
		FreeImage_Initialise();
		auto freeImgVersion = FreeImage_GetVersion();
		auto freeImgCopyright = FreeImage_GetCopyrightMessage();
		uint len1 = std.c.string.strlen(freeImgVersion);
		uint len2 = std.c.string.strlen(freeImgCopyright);

		writefln("FreeImage version: %s\nFreeImage copyright: %s",
				freeImgVersion[0 .. len1], freeImgCopyright[0 .. len2]);
	}

	void initGlfw() {
		//		debug
		//			global.o.writefln("Init GLFW and get current desktop mode...");
		InitFreeImage();
		glfwInit();
		int v1, v2, v3;
		glfwGetVersion(&v1, &v2, &v3);
		writefln("Using glfw version; %s.%s.%s", v1, v2, v3);
		glfwGetDesktopMode(&desktopMode);
	}

	private int testExtension(string name) {
		int ret = glfwExtensionSupported(cast(char*) toStringz(name));
		writefln("glfwExtensionSupported: %s = %s", name, ret);
		return ret;
	}

	void printLog(string msg, GLuint obj) {
		int infologLength = 0;
		int maxLength;

		if(gl3.glIsShader(obj))
			gl3.glGetShaderiv(obj, gl3.GL_INFO_LOG_LENGTH, &maxLength);
		else
			gl3.glGetProgramiv(obj, gl3.GL_INFO_LOG_LENGTH, &maxLength);

		char[] infoLog = new char[](maxLength);

		if(gl3.glIsShader(obj))
			gl3.glGetShaderInfoLog(obj, maxLength, &infologLength, infoLog.ptr);
		else
			gl3.glGetProgramInfoLog(obj, maxLength, &infologLength, infoLog.ptr);

		if(infologLength > 0)
			writefln("%s %s\n", msg, infoLog);
	}

	void initGlExtensionMethods() {
		if(testExtension("GL_ARB_vertex_shader") == 1 && testExtension(
				"GL_ARB_fragment_shader") == 1) {
			debug
				writefln(
						"Imamo :) GL_ARB_vertex_shader i GL_ARB_fragment_shader");

			mixin(gl3.getMethodPointer("glCreateShader"));
			mixin(gl3.getMethodPointer("glShaderSource"));
			mixin(gl3.getMethodPointer("glCompileShader"));
			mixin(gl3.getMethodPointer("glCreateProgram"));
			mixin(gl3.getMethodPointer("glAttachShader"));
			mixin(gl3.getMethodPointer("glLinkProgram"));
			mixin(gl3.getMethodPointer("glUseProgram"));

			mixin(gl3.getMethodPointer("glIsShader"));
			mixin(gl3.getMethodPointer("glGetShaderiv"));
			mixin(gl3.getMethodPointer("glGetProgramiv"));
			mixin(gl3.getMethodPointer("glGetShaderInfoLog"));
			mixin(gl3.getMethodPointer("glGetProgramInfoLog"));

			mixin(gl3.getMethodPointer("glGetUniformLocation"));
			mixin(gl3.getMethodPointer("glUniform3fv"));
			mixin(gl3.getMethodPointer("glUniform3f"));
			mixin(gl3.getMethodPointer("glUniform1f"));

			//http://www.lighthouse3d.com/opengl/glsl/index.php?oglexample1

			GLuint vertexShader = gl3.glCreateShader(gl3.GL_VERTEX_SHADER);
			GLuint fragmentShader = gl3.glCreateShader(gl3.GL_FRAGMENT_SHADER);

			string vertexShaderSrc = import("vertexShader.glsl");

			writefln("Shader = %s, with source = %s", vertexShader,
					vertexShaderSrc);

			string fragmentShaderSrc = import("fragmentShader.glsl");

			writefln("Shader = %s, with source = %s", fragmentShader,
					fragmentShaderSrc);

			char* srcVertexShader = cast(char*) &vertexShaderSrc[0];
			char* srcFragmentShader = cast(char*) &fragmentShaderSrc[0];

			gl3.glShaderSource(vertexShader, 1, &srcVertexShader, null);
			gl3.glShaderSource(fragmentShader, 1, &srcFragmentShader, null);
			gl3.glCompileShader(vertexShader);
			printLog("vertexShader: ", vertexShader);
			gl3.glCompileShader(fragmentShader);
			printLog("fragmentShader: ", fragmentShader);

			auto p = gl3.glCreateProgram();
			gl3.glAttachShader(p, vertexShader);
			gl3.glAttachShader(p, fragmentShader);
			gl3.glLinkProgram(p);

			global.glslCameraPosition = gl3.glGetUniformLocation(p,
					"CameraPosition");
			global.glslFadeOffDist = gl3.glGetUniformLocation(p, "FadeOffDist");

			printLog("program: ", p);
			gl3.glUseProgram(p);

			writeln("After shader source i compile");
		} else {
			debug
				writefln(
						"Nemamo :( GL_ARB_vertex_shader i GL_ARB_fragment_shader");
		}

	}

	void registerCallbacks() {
		//		debug
		//			global.o.writefln("register callbacks...");
		glfwSetWindowSizeCallback(cast(GLFWwindowsizefun) &windowResizeFunc);

		glfwSetKeyCallback(cast(GLFWkeyfun) &keyCallbackFunc);
		glfwSetCharCallback(cast(GLFWcharfun) &characterCallbackFunc);

		glfwSetMouseWheel(0);

		glfwSetMousePosCallback(cast(GLFWmouseposfun) &mousePosFunc);
		glfwSetMouseButtonCallback(cast(GLFWmousebuttonfun) &mouseButtonFunc);
		glfwSetMouseWheelCallback(cast(GLFWmousewheelfun) &mouseWheelFunc);
	}

	void setPerspective() {
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();

		gluPerspective(
				45,
				cast(GLfloat) conf.getIntParam("resX") / cast(GLfloat) conf.getIntParam(
						"resY"), 0.1f, 10000.0f);
		gluLookAt(scene.cameraPosition.x, scene.cameraPosition.y,
				scene.cameraPosition.z, scene.cameraLookAt.x,
				scene.cameraLookAt.y, scene.cameraLookAt.z, 0.0, 1.0, 0.0);
	}

	void setOrtho() {
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrtho(0, global.conf.getIntParam("resX"), global.conf.getIntParam(
				"resY"), 0, 0, 1.0);
	}

	void setModelView() {
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
	}

	void showWindow() {
		if(!glfwOpenWindow(getIntParam("resX"), getIntParam("resY"), 0, 0, 0,
				0, getIntParam("depthBits"), 0, currentWindowType)) {
			glfwTerminate();
			return;
		}
		glfwEnable(GLFW_MOUSE_CURSOR);

		glfwEnable(GLFW_STICKY_KEYS);
		glfwEnable(GLFW_KEY_REPEAT);
		glfwSwapInterval(0);

		glClearColor(bgColor[0], bgColor[1], bgColor[2], 0.0f);

		glPolygonMode(GL_FRONT, GL_FILL);
		glPolygonMode(GL_BACK, GL_LINE);

		glClearDepth(1.0f);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LEQUAL);
		//glEnable(GL_POINT_SMOOTH);
		glDrawBuffer(GL_FRONT_AND_BACK);
	}

	void terminateGlfw() {
		//		debug
		//			global.o.writefln("Terminate GLFW...");
		glfwTerminate();
	}

	int nextFileCounter() {
		setIntParam("fileCounter", getIntParam("fileCounter") + 1);
		saveConfigFile("ifs3d_init.txt");
		return getIntParam("fileCounter");
	}

	int getIntParam(string paramName) {
		if(!(paramName in intParams)) {
			throw new Exception("Int param " ~ paramName ~ " not found");
		}
		return intParams[paramName];
	}

	void setIntParam(string paramName, int value) {
		if(paramName == "")
			return;
		if(!(paramName in intParams)) {
			throw new Exception("Int param " ~ paramName ~ " not found");
		}
		intParams[paramName] = value;
	}

	int[char[]] intParams;
	char[char[]] stringParams;

	bool drawTransAndAxes = true;
	GLFWvidmode desktopMode;
	int currentWindowType = GLFW_WINDOW;
}