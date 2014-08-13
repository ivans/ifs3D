module ivan.ifs3d.gameloop;

private {
	import deimos.glfw.glfw3;
	import std.string, std.stdio;
	import ivan.ifs3d.scene;
	import ivan.ifs3d.global;

	alias ivan.ifs3d.global global;
}

class GameLoop {
	this() {
		t0 = glfwGetTime();
	}

	public void delegate() draw;

	private double time = 0.0;
	public double t0 = 0.0, fps;
	int frames = 0;
	bool running = true;

	void calculateFps() {
		time = glfwGetTime();
		if((time - t0) > 1.0 || frames == 0) {
			fps = cast(double) frames / (time - t0);
			t0 = time;
			frames = 0;

			string titlestr = std.string.format("3D IFS (%sfps)\0", fps);
			debug writefln("%s", titlestr);
			glfwSetWindowTitle( global.glfwWindow, cast(char*)titlestr.ptr );
		}
		frames++;
	}

	void start() {
		while(running) {
			calculateFps();
			glfwGetCursorPos( global.glfwWindow, &global.mouse.X, &global.mouse.Y );
			draw();
			auto notKeyEsc = !glfwGetKey( global.glfwWindow, GLFW_KEY_ESCAPE );
			auto visible = glfwGetWindowAttrib( global.glfwWindow, GLFW_VISIBLE ) != 0;
			running = notKeyEsc;// && visible;
		}
	}
}