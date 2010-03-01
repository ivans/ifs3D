module ivan.ifs3d.ifs3d;

private {
	import std.stream, std.cstream;
	import std.stdio, std.string;
	import glfw, freeimage;
	import ivan.ifs3d.config;
	import ivan.ifs3d.scene;
	import ivan.ifs3d.transformation;
	import ivan.ifs3d.keysstate;
	import ivan.ifs3d.global;

	alias ivan.ifs3d.global global;

	import ivan.ifs3d.callback;

	alias ivan.ifs3d.callback callback;
}

import std.c.process;

pragma(lib, "glfwdll.lib");
pragma(lib, "opengl32.lib");
pragma(lib, "glu32.lib");
pragma(lib, "freeimage.lib");

static this() {
	setCallbackDelegates();
}

int main(string[] args) {
	writefln("Welcome to ifs3d, 3D IFS simulator, v2.0.0");
	global.init();
	global.conf.initGlfw();

	global.scene.addTr(new Transformation(0, 0, 0, 2, 2, 2));
	global.scene.addTr(new Transformation(0, 0, 0, 1, 1, 1));
	global.scene.addTr(new Transformation(1, 0, 0, 1, 1, 1));
	global.scene.addTr(new Transformation(1, 1, 0, 1, 1, 1));

	global.scene.updateTransformationMatrix();

	if(args.length == 2) {
		global.scene = new Scene(new std.stream.File(args[1], FileMode.In));
	}

	global.loop.draw = {
		if(clearscreen > 0) {
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			clearscreen--;
		}

		global.conf.setOrtho();
		//crtaj sučelje

		global.conf.setPerspective();
		global.conf.setModelView();
		//crtaj fraktal

		scene.draw();

		if(conf.drawTransAndAxes == true) {
			scene.drawTrans(bgColor[0], bgColor[1], bgColor[2]);
			scene.drawCoordinateSystem();
		}

		glfwSwapBuffers();
		global.o.flush();

		processMouseEvents();
	};

	global.conf.showWindow();
	global.conf.registerCallbacks();
	global.conf.initGlExtensionMethods();

	auto glRenderer = cast(char*) glGetString(GL_RENDERER);
	auto glVersion = cast(char*) glGetString(GL_VERSION);
	auto glVendor = cast(char*) glGetString(GL_VENDOR);
	auto glExtensions = cast(char*) glGetString(GL_EXTENSIONS);

	writefln("GL_RENDERER   = %s", glRenderer[0 .. std.c.string.strlen(
			glRenderer)]);
	writefln("GL_VERSION    = %s",
			glVersion[0 .. std.c.string.strlen(glVersion)]);
	writefln("GL_VENDOR     = %s", glVendor[0 .. std.c.string.strlen(glVendor)]);
	writefln("GL_EXTENSIONS = %s", glExtensions[0 .. std.c.string.strlen(
			glExtensions)]);

	try {
		writefln("Starting main loop...");
		global.loop.start();
		writefln("Main loop finished...");
	} catch(Exception e) {
		writefln("Exception was: %s", e.msg);
	}

	writefln("Terminating console thread...");
	global.consoleThread.terminate(true);
	//Ovo više ne radi na D2
	//global.o.writefln("Waiting for thread to terminate...");
	//global.consoleThread.wait(1000);

	global.conf.terminateGlfw();

	return 0;
}

void processMouseEvents() {
	if(mouse.Left == true) {
		if(keys.lShift == true) {
			scene.moveCameraLookAt(mouse.XDelta, mouse.YDelta);
			conf.clrscr();
		} else {
			scene.moveSelectedTrans(mouse.XDelta, mouse.YDelta);
			conf.clrscr();
		}
	}

	if(mouse.Right == true) {
		if(keys.lAlt == true) {
			scene.scaleSelectedTrans(mouse.XDelta, mouse.YDelta);
			conf.clrscr();
		} else if(keys.lCtrl == true) {
			scene.ZoomCamera(mouse.YDelta);
			conf.clrscr();
		} else {
			scene.RotateOciste(mouse.XDelta, mouse.YDelta);
			conf.clrscr();
		}
	}

	if(mouse.WheelDelta != 0) {
		scene.ZoomCamera(mouse.WheelDelta);
		conf.clrscr();
	}

	if(keys.insert == true) {
		scene.addTr(new Transformation(0, 0, 0, 1, 1, 1));
		scene.selectedTrans = scene.transformations.length - 1;
		scene.resetPos();
		scene.updateTransformationMatrix();
		glfwSleep(0.2);
		conf.clrscr();
	}
	if(keys.del == true) {
		scene.deleteTransformation();
		glfwSleep(0.2);
		conf.clrscr();
	}

	if(keys.Left == true) {
		scene.selectPrevTransformation;
		glfwSleep(0.2);
		conf.clrscr();
	}
	if(keys.Right == true) {
		scene.selectNextTransformation;
		glfwSleep(0.2);
		conf.clrscr();
	}

	void toZero(ref int val) {
		if(val < 0)
			val++;
		else if(val > 0)
			val--;
	}

	toZero(mouse.WheelDelta);
	toZero(mouse.XDelta);
	toZero(mouse.YDelta);
}

void setCallbackDelegates() {
	debug
		writefln("void setCallbackDelegates()");

	callback.windowResize = (int w, int h) {
		debug
			global.o.writefln("Resizing to: (", w, ",", h, ")");
		global.conf.setIntParam("resX", w);
		global.conf.setIntParam("resY", h);
		glViewport(0, 0, w, h);
		conf.clrscr();
	};

	callback.mouseWheel = (int pos) {
		debug
			global.o.writefln("Mouse scroll: ", pos);
		mouse.WheelDelta = pos - mouse.WheelPos;
		mouse.WheelPos = pos;
	};

	callback.mousePos = (int x, int y) {
		static counter = 0;
		mouse.XDelta = x - mouse.X;
		mouse.YDelta = y - mouse.Y;
		debug
			global.o.writefln("Mouse: pos(%s, %s), delta(%s, %s), %s", x, y,
					mouse.XDelta, mouse.YDelta, counter++);
		mouse.X = x;
		mouse.Y = y;
	};

	callback.mouseButton = (int button, int action) {
		debug
			global.o.writefln("Mouse button: ", button, ", ", action);

		mouse.LeftOld = mouse.Left;
		mouse.RightOld = mouse.Right;
		mouse.MiddleOld = mouse.Middle;

		if(action == GLFW_PRESS) {
			if(button == GLFW_MOUSE_BUTTON_LEFT)
				mouse.Left = true;
			if(button == GLFW_MOUSE_BUTTON_RIGHT)
				mouse.Right = true;
			if(button == GLFW_MOUSE_BUTTON_MIDDLE)
				mouse.Middle = true;
		} else {
			if(button == GLFW_MOUSE_BUTTON_LEFT)
				mouse.Left = false;
			if(button == GLFW_MOUSE_BUTTON_RIGHT)
				mouse.Right = false;
			if(button == GLFW_MOUSE_BUTTON_MIDDLE)
				mouse.Middle = false;
		}
	};

	callback.keyCallback = (int key, int action) {
		debug
			global.o.writefln("Key: ", key, ", ", action);
		keys.update(key, action);
	};

	callback.characterCallback = (int character, int state) {
		debug
			global.o.writefln("Character: ", character, ", ", state);
		char c = cast(char) character;
		if(state == GLFW_PRESS) {
			switch(c) {
				case 'a':
					scene.changeFunctionOfSelected(-1);
					conf.clrscr();
				break;
				case 'd':
					scene.changeFunctionOfSelected(1);
					conf.clrscr();
				break;
				case '.':
					scene.printPoint ^= true;
				break;
				case 's':
					scene.save(conf.nextFileCounter);
				break;
				case 'q':
					scene.rotateSelected(-1);
					conf.clrscr();
				break;
				case 'w':
					scene.rotateSelected(1);
					conf.clrscr();
				break;
				case 'e':
					scene.setRotVectorOfSelected();
					conf.clrscr();
				break;
				case 'r':
					scene.resetPos();
				break;
				case 't':
					conf.drawTransAndAxes ^= true;
					conf.clrscr();
				break;
				case 'b': {
					debug
						global.o.writefln("Character == ", c);

					if(bgColor is bgColorWhite)
						bgColor = bgColorBlack;
					else if(bgColor is bgColorBlack)
						bgColor = bgColorWhite;
					else
						bgColor = bgColorWhite;

					glClearColor(bgColor[0], bgColor[1], bgColor[2], 0.0f);
					conf.clrscr();
					global.scene.clearImageBufferToBackgroundColor();
					break;
				}
				case '+':
					scene.increaseStack();
				break;
				case '-':
					scene.decreaseStack();
				break;
				default:
				break;
			}
		}
	};

	debug
		writefln("~void setCallbackDelegates()");
}