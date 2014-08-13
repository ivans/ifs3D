module ivan.ifs3d.global;

private {
	import std.stdio;
	import ivan.ifs3d.config;
	import ivan.ifs3d.gameloop;
	import ivan.ifs3d.mousestate;
	import ivan.ifs3d.keysstate;
	import ivan.ifs3d.point;
	import ivan.ifs3d.scene;
	import ivan.ifs3d.consolethread;
	import freeimage;
	import deimos.glfw.glfw3;// import glfw;
}

package Config conf;
package GameLoop loop;
package MouseState mouse;
package Scene scene;
package KeysState keys;
package int clearscreen = 2;
package ConsoleThread consoleThread;
package GLFWwindow* glfwWindow;

package float[3] bgColorBlack = [0, 0, 0];
package float[3] bgColorWhite = [1, 1, 1];
package float[] bgColor;

package int glslCameraPosition;
__gshared int glslFadeOffDist;
package float fadeOffDist = 100;

alias std.cstream.dout o;

static this() {
	debug o.writefln("global.static this()");
	bgColor = bgColorWhite;
}

void init() {
	debug o.writefln("Init Config...");
	conf = new Config("ifs3d_init.txt");
	loop = new GameLoop;
	mouse = new MouseState;
	keys = new KeysState;
	scene = new Scene;
	//consoleThread = new ConsoleThread;
	//consoleThread.start;
}