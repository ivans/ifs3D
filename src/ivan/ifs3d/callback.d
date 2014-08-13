module ivan.ifs3d.callback;

private {
	import ivan.ifs3d.mousestate;
}

void delegate(int w, int h) windowResize;
void delegate(int pos) mouseWheel;
void delegate(int x, int y) mousePos;
void delegate(int button, int action) mouseButton;
void delegate(int key, int action) keyCallback;
void delegate(int character, int state) characterCallback;

extern(System):

	void windowResizeFunc(int w, int h) {
		windowResize(w, h);
	}

	void mouseWheelFunc(int pos) {
		mouseWheel(pos);
	}

	void mousePosFunc(int x, int y) {
		mousePos(x, y);
	}

	void mouseButtonFunc(int button, int action) {
		mouseButton(button, action);
	}

	void keyCallbackFunc(int key, int action) {
		keyCallback(key, action);
	}

	void characterCallbackFunc(int character, int state) {
		characterCallback(character, state);
	}