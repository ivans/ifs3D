module ivan.ifs3d.ifs3d;

private {
	import std.stdio, std.string;
	import core.thread;
	import core.stdc.string : strlen;
	import deimos.glfw.glfw3, freeimage;
	import ivan.ifs3d.config;
	import ivan.ifs3d.scene;
	import ivan.ifs3d.transformation;
	import ivan.ifs3d.keysstate;
	import ivan.ifs3d.global;

	alias ivan.ifs3d.global global;

	import ivan.ifs3d.callback;
	import gl, gl3 = ivan.ifs3d.gl3, glu;

	alias ivan.ifs3d.callback callback;
}

import core.stdc.stdlib;

//pragma(lib, "glfwdll.lib");
//pragma(lib, "opengl32.lib");
//pragma(lib, "glu32.lib");
//pragma(lib, "freeimage.lib");

//version = log_mouse_events;

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
		debug writefln("Loading scene from file %s given as argument.", args[1]);
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

		gl3.glUniform3f(global.glslCameraPosition, scene.cameraPosition.x, scene.cameraPosition.y, scene.cameraPosition.z);
		gl3.glUniform1f(global.glslFadeOffDist, global.fadeOffDist);

		scene.draw();

		if(conf.drawTransAndAxes == true) {
			//nacrtaj očište kamere (bijela točka)
			scene.drawOciste();
			scene.drawTrans(bgColor[0], bgColor[1], bgColor[2]);
			scene.drawCoordinateSystem();
		}

		glfwSwapBuffers(global.glfwWindow);
		glfwPollEvents();
		//		global.o.flush();

		processMouseEvents();
	};

	global.conf.showWindow();
	global.conf.initGlExtensionMethods();
	global.conf.registerCallbacks();

	auto glRenderer = cast(char*) glGetString(GL_RENDERER);
	auto glVersion = cast(char*) glGetString(GL_VERSION);
	auto glVendor = cast(char*) glGetString(GL_VENDOR);
	auto glExtensions = cast(char*) glGetString(GL_EXTENSIONS);

	writefln("GL_RENDERER   = %s", glRenderer[0 .. strlen(glRenderer)]);
	writefln("GL_VERSION    = %s", glVersion[0 .. strlen(glVersion)]);
	writefln("GL_VENDOR     = %s", glVendor[0 .. strlen(glVendor)]);
	writefln("GL_EXTENSIONS = %s", glExtensions[0 .. strlen(glExtensions)]);

	try {
		writefln("Starting main loop...");
		global.loop.start();
		writefln("Main loop finished...");
	} catch(Exception e) {
		writefln("Exception was: %s", e.msg);
	}

	writefln("Terminating console thread...");
	if(global.consoleThread !is null)
		global.consoleThread.terminate(true);
	//Ovo više ne radi na D2
	//global.o.writefln("Waiting for thread to terminate...");
	//global.consoleThread.wait(1000);

	global.conf.terminateGlfw();

	return 0;
}

void processMouseEvents() {
	if(mouse.Left == true) {
		if(mykeys.lShift == true) {
			scene.moveCameraLookAt(mouse.XDelta, mouse.YDelta);
			conf.clrscr();
		} else {
			scene.moveSelectedTrans(mouse.XDelta, mouse.YDelta);
			conf.clrscr();
		}
	}

	if(mouse.Right == true) {
		if(mykeys.lAlt == true) {
			scene.scaleSelectedTrans(mouse.XDelta, mouse.YDelta);
			conf.clrscr();
		} else if(mykeys.lCtrl == true) {
			scene.ZoomCamera(mouse.YDelta);
			conf.clrscr();
		} else {
			scene.RotateOciste(mouse.XDelta, mouse.YDelta);
			conf.clrscr();
		}
	}

	if(mouse.WheelDelta != 0) {
		scene.ZoomCamera(-mouse.WheelDelta);
		conf.clrscr();
	}

	if(mykeys.insert == true) {
		scene.addTr(new Transformation(0, 0, 0, 1, 1, 1));
		scene.selectedTrans = cast(int)scene.transformations.length - 1;
		scene.resetPos();
		scene.updateTransformationMatrix();
		Thread.sleep(dur!("msecs")(200));
		conf.clrscr();
	}
	if(mykeys.del == true) {
		scene.deleteTransformation();
		Thread.sleep(dur!("msecs")(200));
		conf.clrscr();
	}

	if(mykeys.Left == true) {
		scene.selectPrevTransformation;
		Thread.sleep(dur!("msecs")(200));
		conf.clrscr();
	}
	if(mykeys.Right == true) {
		scene.selectNextTransformation;
		Thread.sleep(dur!("msecs")(200));
		conf.clrscr();
	}

	if(mykeys.Up == true) {
		global.fadeOffDist += 1;
		writefln("FadeOffDist is now %s", global.fadeOffDist);
		conf.clrscr();
		Thread.sleep(dur!("msecs")(100));
	}
	if(mykeys.Down == true) {
		global.fadeOffDist -= 1;
		writefln("FadeOffDist is now %s", global.fadeOffDist);
		conf.clrscr();
		Thread.sleep(dur!("msecs")(100));
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
	debug writefln("void setCallbackDelegates()");

	callback.windowResize = (int w, int h) {
		debug writefln("Resizing to: (", w, ",", h, ")");
		global.conf.setIntParam("resX", w);
		global.conf.setIntParam("resY", h);
		glViewport(0, 0, w, h);
		conf.clrscr();
	};

	callback.mouseWheel = (double xscroll, double yscroll) {
		//debug version(log_mouse_events) writefln("Mouse: scroll: %s, %s", xscroll, yscroll);
		mouse.WheelDelta =  cast(int)yscroll;
		mouse.WheelPos = cast(int)(mouse.WheelPos + yscroll);
	};

	callback.mousePos = (double x, double y) {
		mouse.XDelta = cast(int)(x - mouse.X);
		mouse.YDelta = cast(int)(y - mouse.Y);
		//debug version(log_mouse_events) writefln("Mouse: pos(%s, %s), delta(%s, %s)", x, y, mouse.XDelta, mouse.YDelta);
		mouse.X = x;
		mouse.Y = y;
	};

	callback.mouseButton = (int button, int action, int mods) {
		//debug version(log_mouse_events) writefln("Mouse: button: %s, action: %s", button, action);

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

	callback.keyCallback = (int key, int scancode, int action, int mods) {
		//debug version(log_mouse_events) writefln("Key: ", key, ", ", action);
		mykeys.update(key, action);
	};

	callback.characterCallback = (uint character) {
		//debug version(log_mouse_events) writefln("Character: %s", character);
		char c = cast(char) character;
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
			case 'c':
				writefln("Clearing screen and background buffer...");
				global.scene.clearImageBufferToBackgroundColor();
				conf.clrscr();
			break;
			case 'v':
				global.conf.nextVertexShaderProgram();
				conf.clrscr();
			break;
			case 'b': {
				debug
					version(log_mouse_events) writefln("Character == ", c);

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
			case 'u':
				scene.resizeSelected(1, 0.1);
				conf.clrscr();
			break;
			case 'j':
				scene.resizeSelected(1, -0.1);
				conf.clrscr();
			break;
			case 'i':
				scene.resizeSelected(2, 0.1);
				conf.clrscr();
			break;
			case 'k':
				scene.resizeSelected(2, -0.1);
				conf.clrscr();
			break;
			case 'o':
				scene.resizeSelected(3, 0.1);
				conf.clrscr();
			break;
			case 'l':
				scene.resizeSelected(3, -0.1);
				conf.clrscr();
			break;
			default:
			break;
		}
	};

	debug writefln("~void setCallbackDelegates()");
}
