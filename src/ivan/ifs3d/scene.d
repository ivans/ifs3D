﻿module ivan.ifs3d.scene;

private {
	import deimos.glfw.glfw3, freeimage, gl;
	import std.conv : to;
	import std.math;
	import std.random;
	import std.format : formattedRead;
	import ivan.ifs3d.point;
	import ivan.ifs3d.transformation;
	import std.stdio;
	import std.string : format;
	import ivan.ifs3d.writetga;
	import ivan.ifs3d.config;
	import ivan.ifs3d.types;
}

version = in_mem_buffer_with_z;

class Scene {
	this() {
		cameraPosition = Point(1, 1, 3);
		cameraLookAt = Point(1, 1, 0);
		int w = global.conf.getIntParam("picResX");
		int h = global.conf.getIntParam("picResY");
		version(in_mem_buffer_with_z) {
			buffer = FreeImage_Allocate(w, h, 32);
			zBuffer = new float[][](w, h);
		}
		clearImageBufferToBackgroundColor;
	}

	this(string s) {
		this();
		int count;
		s.formattedRead!"%d\n"(count);
		debug writefln("Count: %s", count);
		s.formattedRead!"%f %f %f\n"(cameraPosition.x, cameraPosition.y, cameraPosition.z);
		s.formattedRead!"%f %f %f\n"(cameraLookAt.x, cameraLookAt.y, cameraLookAt.z);
		debug writefln("Camera: pos: %s, lookAt: %s", cameraPosition, cameraLookAt);

		for(int i = 0; i < count; i++) {
			this.addTr(new Transformation(s));
		}
		debug {
			writeln("Constructing scene from stream: cameraPos = ",
					cameraPosition.toString, "cameraLookaAt = ",
					cameraLookAt.toString);
			writeln(count, " transformations");
			foreach(Transformation t; transformations) {
				writefln(t.toStream());
			}
		}
		this.updateTransformationMatrix();
		this.recalculateVolume();
	}

	string toStream() {
		string result = format!"%s\n"(transformations.length.to!string);
		result ~= format!"%s %s %s\n"(cameraPosition.x, cameraPosition.y, cameraPosition.z);
		result ~= format!"%s %s %s\n"(cameraLookAt.x, cameraLookAt.y, cameraLookAt.z);
		foreach(t; transformations) {
			result ~= format!"%s\n"(t.toStream);
		}
		return result;
	}

	void drawOciste() {
		glPointSize(5);
		glBegin(GL_POINTS);
		glColor3f(1, 1, 1);
		glVertex3f(cameraLookAt.x, cameraLookAt.y, cameraLookAt.z);
		glEnd();
	}

	short lastTr = 0;

	void fillDisplayList() {
		for(int i = 0; i < POINTS_PER_ITERATION; i++) {
			int sumR = 0, sumG = 0, sumB = 0;
			for(int msi = cast(int)(moveStack.length-1); msi >= 0; msi--) {
				sumR += colors[(moveStack[msi]) % colors.length][0];
				sumG += colors[(moveStack[msi]) % colors.length][1];
				sumB += colors[(moveStack[msi]) % colors.length][2];
			}
			colorBuffer[i][0] = cast(ubyte) (sumR / moveStack.length);
			colorBuffer[i][1] = cast(ubyte) (sumG / moveStack.length);
			colorBuffer[i][2] = cast(ubyte) (sumB / moveStack.length);

			//colorBuffer[i][0] = getColor(0);
			//colorBuffer[i][1] = getColor(1);
			//colorBuffer[i][2] = getColor(2);

			positions[i][0] = x;
			positions[i][1] = y;
			positions[i][2] = z;

			synchronized(this)
				transformations[lastTr = nlRand()].transformPoint(x, y, z);

			synchronized(this) {
				moveStack[moveStackPos = (moveStackPos + 1) % moveStack.length] = lastTr;
			}
		}
	}

	ubyte getColor(int index) {
		int suma = 0;
		for(int i=cast(int)(moveStack.length-1); i>=0; i--) {
			suma += cast(int) (colors[(moveStack[i]) % colors.length][index]);
		}
		return cast(ubyte) (suma / moveStack.length);
	}

	short nlRand() {
		//TODO proučiti da li je ovaj rand ok!
		ifsfloat randNum = (std.random.uniform(0, 10000) % (transformationVolumeSum));
		ifsfloat counter = 0;
		for(long index = 1; index < transformations.length; index++) {
			counter += abs(transformations[cast(int) index].area);
			if(randNum < counter)
				return cast(short) index;
		}
		return 0;
	}

	void drawDisplayList() {
		glPointSize(1);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		glVertexPointer(3, GL_FLOAT, 0, positions.ptr);
		glColorPointer(3, GL_UNSIGNED_BYTE, 0, colorBuffer.ptr);
		glDrawArrays(cast(uint)GL_POINTS, 0, cast(int)(positions.length/3));
	}

	void draw() {

		fillDisplayList();

		version(in_mem_buffer_with_z) {
			glFeedbackBuffer(cast(GLsizei)feedbackBuffer.length, cast(GLenum)GL_3D_COLOR, cast(GLfloat*)feedbackBuffer.ptr);
			glRenderMode(GL_FEEDBACK);
			drawDisplayList();
		}

		int size = glRenderMode(GL_RENDER);

		version(in_mem_buffer_with_z) {
			float mx = cast(float) global.conf.getIntParam("picResX") / global.conf.getIntParam("resX");
			float my = cast(float) global.conf.getIntParam("picResY") / global.conf.getIntParam("resY");
			for(int i = 0; i < size; i += 8) {
				//feedback buffer content:
				//  0   1 2 3 4 5 6 7
				//token x y z r g b a
				uint x = cast(uint) (feedbackBuffer[i + 1]/*feedbackBuffer[i+3]*/* mx);
				uint y = cast(uint) (feedbackBuffer[i + 2]/*feedbackBuffer[i+3]*/* my);
				//if(x>100&&x<150)global.o.writefln(" =======================> Z = ", feedbackBuffer[i+3]);
				if(x >= 0 && x < zBuffer.length && y > 0 && y < zBuffer[0].length) {
					if(feedbackBuffer[i + 3] < zBuffer[x][y]) {
						zBuffer[x][y] = feedbackBuffer[i + 3];
						FreeImage_SetPixelColor(
								buffer,
								x,
								y,
								ivan.ifs3d.writetga.getColor(
										cast(ubyte) (feedbackBuffer[i + 6] * 255),
										cast(ubyte) (feedbackBuffer[i + 5] * 255),
										cast(ubyte) (feedbackBuffer[i + 4] * 255),
										cast(ubyte) (feedbackBuffer[i + 7] * 255)));
					}
				}
			}
		}

		drawDisplayList();
	}

	void clearImageBufferToBackgroundColor() {
		int w = global.conf.getIntParam("picResX");
		int h = global.conf.getIntParam("picResY");
		version(in_mem_buffer_with_z) {
			for(uint y = 0; y < h; y++) {
				for(uint x = 0; x < w; x++) {
					FreeImage_SetPixelColor(buffer, x, y, ivan.ifs3d.writetga.getColor(cast(ubyte)global.bgColor[2], cast(ubyte)global.bgColor[1], cast(ubyte)global.bgColor[0]));
				}
			}
			foreach(ref line; zBuffer)
				foreach(ref elem; line)
					elem = 100;
		}
	}

	public void increaseStack() {
		synchronized(this)
			moveStack.length = moveStack.length + 1;
	}

	public void decreaseStack() {
		int size = cast(int)(moveStack.length - 1);
		if(size > 0) {
			synchronized(this)
				moveStack.length = size;
		}
	}

	void addTr(Transformation t) {
		transformations ~= t;
		this.recalculateVolume();
	}

	public void setRotVectorOfSelected() {
		ifsfloat vx = cameraPosition.x - cameraLookAt.x;
		ifsfloat vy = cameraPosition.y - cameraLookAt.y;
		ifsfloat vz = cameraPosition.z - cameraLookAt.z;

		ifsfloat len = sqrt(vx * vx + vy * vy + vz * vz);
		vx /= len;
		vy /= len;
		vz /= len;

		transformations[selectedTrans].Rx = vx;
		transformations[selectedTrans].Ry = vy;
		transformations[selectedTrans].Rz = vz;

		if(selectedTrans == 0) {
			this.updateTransformationMatrix();
		} else {
			transformations[selectedTrans].CalculateTransformationMatrix2(
					transformations[0]);
		}
	}

	public void ZoomCamera(int mouseYDelta) {
		debug writefln("ZoomCamera, cameraPos = %s, cameraLookAt = %s, mouseYDela = %s", cameraPosition, cameraLookAt, mouseYDelta);
		ifsfloat vx = cameraPosition.x - cameraLookAt.x;
		ifsfloat vy = cameraPosition.y - cameraLookAt.y;
		ifsfloat vz = cameraPosition.z - cameraLookAt.z;

		ifsfloat div = mouseYDelta > 0 ? 1.1f : 1 / 1.1f;
		if(mouseYDelta == 0)
			div = 1;

		vx *= div;
		vy *= div;
		vz *= div;

		cameraPosition.x = vx + cameraLookAt.x;
		cameraPosition.y = vy + cameraLookAt.y;
		cameraPosition.z = vz + cameraLookAt.z;
	}

	public void moveCameraLookAt(int mouseXDelta, int mouseYDelta) {
		ifsfloat vx = cameraPosition.x - cameraLookAt.x;
		ifsfloat vy = cameraPosition.y - cameraLookAt.y;
		ifsfloat vz = cameraPosition.z - cameraLookAt.z;

		ifsfloat len = sqrt(vx * vx + vy * vy + vz * vz);
		vx /= len;
		vy /= len;
		vz /= len;

		cameraLookAt.x += vz * mouseXDelta / 100f;
		cameraLookAt.y += -1 * mouseYDelta / 100f;
		cameraLookAt.z += -vx * mouseXDelta / 100f;
	}

	public void RotateOciste(int mouseXDelta, int mouseYDelta) {
		ifsfloat vx = cameraPosition.x - cameraLookAt.x;
		ifsfloat vy = cameraPosition.y - cameraLookAt.y;
		ifsfloat vz = cameraPosition.z - cameraLookAt.z;

		ifsfloat len = sqrt(vx * vx + vy * vy + vz * vz);
		vx /= len;
		vy /= len;
		vz /= len;

		ifsfloat[4][4] M;
		Transformation.MakeRotationMatrix(mouseXDelta / 200f, 0, 1, 0, M);
		Transformation.transformPoint(this.cameraPosition.x, this.cameraPosition.y, this.cameraPosition.z, M);
		Transformation.MakeRotationMatrix(mouseYDelta / 200f, vz, 0, -vx, M);
		Transformation.transformPoint(cameraPosition.x, cameraPosition.y, cameraPosition.z, M);
	}

	public void scaleSelectedTrans(ifsfloat dx, ifsfloat dy) {
		ifsfloat vx = cameraPosition.x - cameraLookAt.x;
		ifsfloat vy = cameraPosition.y - cameraLookAt.y;
		ifsfloat vz = cameraPosition.z - cameraLookAt.z;
		ifsfloat len = sqrt(vx * vx + vy * vy + vz * vz);
		vx /= len;
		vy /= len;
		vz /= len;

		transformations[selectedTrans].Wx = transformations[selectedTrans].Wx + vz * dx * len / 1000f;
		transformations[selectedTrans].Wy = transformations[selectedTrans].Wy - dy * len / 1000f;
		transformations[selectedTrans].Wz = transformations[selectedTrans].Wz - dx * vx * len / 1000f;

		updateSomeOfTransformationMatrix();
		this.recalculateVolume();
	}

	public void moveSelectedTrans(ifsfloat dx, ifsfloat dy) {
		ifsfloat vx = cameraPosition.x - cameraLookAt.x;
		ifsfloat vy = cameraPosition.y - cameraLookAt.y;
		ifsfloat vz = cameraPosition.z - cameraLookAt.z;
		ifsfloat len = sqrt(vx * vx + vy * vy + vz * vz);
		vx /= len;
		vy /= len;
		vz /= len;

		transformations[selectedTrans].X = transformations[selectedTrans].X + len * dx * vz / 1000f;
		transformations[selectedTrans].Y = transformations[selectedTrans].Y - len * dy * (vx * vx + vz * vz) / 1000f;
		transformations[selectedTrans].Z = transformations[selectedTrans].Z + len * dx * -vx / 1000f;

		transformations[selectedTrans].X = transformations[selectedTrans].X + len * dy * -vx * vy / 1000f;
		transformations[selectedTrans].Y = transformations[selectedTrans].Y - len * dy * (vx * vx + vz * vz) / 1000f;
		transformations[selectedTrans].Z = transformations[selectedTrans].Z + len * dy * -vy * vz / 1000f;

		updateSomeOfTransformationMatrix();
		this.recalculateVolume();
	}

	void updateTransformationMatrix() {
		for(int i = 0; i < transformations.length; i++) {
			transformations[i].CalculateTransformationMatrix2(transformations[0]);
		}
	}

	void drawTrans(ifsfloat r, ifsfloat g, ifsfloat b) {
		foreach(int i, t; transformations) {
			if(i != selectedTrans)
				t.draw(1 - r, 1 - g, 1 - b);
		}
		glLineWidth(2);
		transformations[selectedTrans].draw(255, 255, 0);
		glLineWidth(1);
	}

	void drawCoordinateSystem() {
		glBegin(GL_LINES);
		// red axis
		glColor3f(1, 0, 0);
		glVertex2f(-5, 0);glVertex2f(5, 0);
		glVertex2f(-5, -1);glVertex2f(5, -1);
		glVertex2f(-5, 1);glVertex2f(5, 1);
		glVertex2f(-5, -2);glVertex2f(5, -2);
		glVertex2f(-5, 2);glVertex2f(5, 2);
		// green axis
		glColor3f(0, 1, 0);
		glVertex2f(0, -5);glVertex2f(0, 5);
		glVertex2f(-1, -5);glVertex2f(-1, 5);
		glVertex2f(1, -5);glVertex2f(1, 5);
		glVertex2f(-2, -5);glVertex2f(-2, 5);
		glVertex2f(2, -5);glVertex2f(2, 5);
		// blue axis
		glColor3f(0, 0, 1);
		glVertex3f(0, 0, -5);glVertex3f(0, 0, 5);
		glVertex3f(0, -1, -5);glVertex3f(0, -1, 5);
		glVertex3f(0, 1, -5);glVertex3f(0, 1, 5);
		glVertex3f(0, -2, -5);glVertex3f(0, -2, 5);
		glVertex3f(0, 2, -5);glVertex3f(0, 2, 5);
		glEnd();
	}

	void selectNextTransformation() {
		selectedTrans = cast(int)((selectedTrans + 1) % transformations.length);
		writefln("Selected tansformation: %s", selectedTrans);
	}

	void selectPrevTransformation() {
		selectedTrans--;
		if(selectedTrans < 0) {
			selectedTrans += transformations.length;
		}
		writefln("Selected tansformation: %s", selectedTrans);
	}

	void deleteTransformation() {
		Transformation[] novi;
		for(int i = 0; i < transformations.length; i++) {
			if(i != selectedTrans)
				novi ~= transformations[i];
		}

		selectedTrans--;
		if(selectedTrans < 0)
			selectedTrans = 0;

		synchronized(this) {
			transformations = novi;
			updateSomeOfTransformationMatrix();
		}
		moveStack[] = 0;
		this.recalculateVolume();
	}

	void updateSomeOfTransformationMatrix() {
		if(selectedTrans == 0) {
			this.updateTransformationMatrix();
		} else {
			transformations[selectedTrans].CalculateTransformationMatrix2(transformations[0]);
		}
	}

	void resizeSelected(short direction, ifsfloat amount) {
		if(direction == 1) {
			transformations[selectedTrans].Wx = transformations[selectedTrans].Wx + amount;
		} else if(direction == 2) {
			transformations[selectedTrans].Wy = transformations[selectedTrans].Wy + amount;
		} else if(direction == 3) {
			transformations[selectedTrans].Wz = transformations[selectedTrans].Wz + amount;
		}
		updateSomeOfTransformationMatrix();
		this.recalculateVolume();
	}

	void rotateSelected(int sign) {
		transformations[selectedTrans].Ra = sign * PI / 32 + transformations[selectedTrans].Ra;
		updateSomeOfTransformationMatrix();
	}

	void changeFunctionOfSelected(int direction) {
		int f = transformations[selectedTrans].func;
		f += direction;
		if(f < 0)
			f += Transformation.numberOfFunc;
		else
			f %= Transformation.numberOfFunc;
		debug writefln("Selected function is now %s", f);
		transformations[selectedTrans].func = f;
	}

	void saveImage(string fileName) {
		glFinish();
		ivan.ifs3d.writetga.writeJpeg(fileName);
	}

	void save(int n) {
		// save file names
		string definition     = format("fractal%05d.ifs3d\0",n);
		string picture        = format("fractal%05d.jpeg\0",n);
		string pictureHighres = format("fractal%05d-highres.jpeg\0",n);
		string pictureBicubic = format("fractal%05d-bicubic.jpeg\0",n);

		// save scene definition
		writefln("Saving scene definition file...");
		File f = File(definition, "w");
		f.write(this.toStream());

		// save highres image
		version(in_mem_buffer_with_z) {
			writef(format("Saving high res (%sx%s) image...", global.conf.getIntParam("picResX"), global.conf.getIntParam("picResY")));
			FIBITMAP* nova24bit = FreeImage_ConvertTo24Bits(buffer);
			FreeImage_Save(FREE_IMAGE_FORMAT.FIF_JPEG, nova24bit, cast(char*)pictureHighres, JPEG_QUALITYSUPERB);
			FreeImage_Unload(nova24bit);
			writefln(" done");

			FIBITMAP* pict32bit = FreeImage_ConvertTo32Bits(buffer);
			FreeImage_AdjustGamma(pict32bit, (global.conf.getIntParam("adjGamma")+100)/20);
			FreeImage_AdjustBrightness(pict32bit, global.conf.getIntParam("adjBrightness"));
			FreeImage_AdjustContrast(pict32bit, global.conf.getIntParam("adjContrast"));
			FIBITMAP* nova = FreeImage_Rescale(pict32bit, global.conf.getIntParam("picSmallX"), global.conf.getIntParam("picSmallY"), FREE_IMAGE_FILTER.FILTER_BICUBIC);
			nova24bit = FreeImage_ConvertTo24Bits(nova);
			writef(format("Saving resampled (%sx%s) image...", global.conf.getIntParam("picSmallX"), global.conf.getIntParam("picSmallY")));
			FreeImage_Save(FREE_IMAGE_FORMAT.FIF_JPEG,nova24bit,cast(char*)pictureBicubic,JPEG_QUALITYSUPERB);
			writefln(" done");
			FreeImage_Unload(nova);
			FreeImage_Unload(nova24bit);
			FreeImage_Unload(pict32bit);
		}

		writef("Saving screen capture image...");
		saveImage(picture);
		writefln(" done");
	}

	void resetPos() {
		x = 0;
		y = 0;
		z = 0;
	}

	package int selectedTrans = 0;
	package Transformation[] transformations;
	private ifsfloat transformationVolumeSum = 0;

	void recalculateVolume() {
		transformationVolumeSum = 0;
		foreach(int index, rect; transformations) {
			if(index != 0) {
				transformationVolumeSum += abs(rect.area);
			}
		}
	}

	package Point cameraPosition;
	package Point cameraLookAt;

	package ifsfloat x = 0, y = 0, z = 0;
	package bool printPoint = false;

	private ubyte[][] colors = [
		[125, 125, 125],
		[255,   0,   0],
		[  0, 255,   0],
		[  0,   0, 255],
		[255, 255,   0],
		[  0, 255, 255],
		[255,   0, 255],
		[255, 255, 255],
		[100, 155, 255],
		[155,   0,  55]
	, ];

	static int POINTS_PER_ITERATION = 20_000;

	version(in_mem_buffer_with_z) {
		FIBITMAP* buffer;
		float[][] zBuffer;
		static float[] feedbackBuffer;
	}

	//positions and colorBuffer is used for display lists
	static float[3][] positions;
	static ubyte[3][] colorBuffer;
	static short[] moveStack;
	static uint moveStackPos = 0;

	static this() {
		positions.length = POINTS_PER_ITERATION;
		colorBuffer.length = POINTS_PER_ITERATION;
		version(in_mem_buffer_with_z)
			feedbackBuffer.length = POINTS_PER_ITERATION * 8; //token x y z r g b a;
		moveStack.length = 5;
	}
}
