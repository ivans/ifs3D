module ivan.ifs3d.callback;

private {
	import ivan.ifs3d.mousestate;
	import deimos.glfw.glfw3;
	import std.stdio;
}

void delegate(int w, int h) windowResize;
void delegate(double xscroll, double yscroll) mouseWheel;
void delegate(double x, double y) mousePos;
void delegate(int button, int action, int mods) mouseButton;
void delegate(int key, int scancode, int action, int mods) keyCallback;
void delegate(uint character) characterCallback;

extern(System):

	void windowResizeFunc(GLFWwindow* glfwWindow, int w, int h) {
		windowResize(w, h);
	}

	void mouseWheelFunc(GLFWwindow* glfwWindow, double xscroll, double yscroll) {
		mouseWheel(xscroll, yscroll);
	}

	void mousePosFunc(GLFWwindow* glfwWindow, double x, double y) {
		mousePos(x, y);
	}

	void mouseButtonFunc(GLFWwindow* glfwWindow, int button, int action, int mods) {
		mouseButton(button, action, mods);
	}

	void keyCallbackFunc(GLFWwindow* glfwWindow, int key, int scancode, int action, int mods) {
		keyCallback(key, scancode, action, mods);
	}

	void characterCallbackFunc(GLFWwindow* glfwWindow, uint character) {
		characterCallback(character);
	}
