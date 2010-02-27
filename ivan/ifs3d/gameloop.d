module ivan.ifs3d.gameloop;

private {
	import glfw;
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
			glfw.glfwSetWindowTitle(cast(char*) titlestr.ptr);
		}
		frames++;
	}

	void start() {
		while(running) {
			debug
				writeln("Loop time = ", time);
			calculateFps();
			debug
				writeln("Getting mouse pos");
			glfwGetMousePos(&global.mouse.X, &global.mouse.Y);
			debug
				writeln("Drawing...");
			draw();
			debug
				writeln("Calc if still running");
			running = !glfwGetKey(GLFW_KEY_ESC) && glfwGetWindowParam(
					GLFW_OPENED);
			debug
				writeln("Running = ", running);
		}
	}
}