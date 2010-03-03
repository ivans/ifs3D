module ivan.ifs3d.transformation;

private {
	import std.math;
	import std.stream;
	import std.stdio;
	import glfw;

	import ivan.ifs3d.types;
}

//version = draw_transformation_star_point;

class Transformation {

	this(ifsfloat x, ifsfloat y, ifsfloat z) {
		this(x, y, z, 1, 1, 1);
	}

	this(ifsfloat x, ifsfloat y, ifsfloat z, ifsfloat wx, ifsfloat wy,
			ifsfloat wz) {
		this(x, y, z, wx, wy, wz, 0, 1, 0, 0);
	}

	this(ifsfloat x, ifsfloat y, ifsfloat z, ifsfloat wx, ifsfloat wy,
			ifsfloat wz, ifsfloat ra, ifsfloat rx, ifsfloat ry, ifsfloat rz) {
		this(x, y, z, wx, wy, wz, ra, rx, ry, rz, 0);
	}

	this(ifsfloat x, ifsfloat y, ifsfloat z, ifsfloat wx, ifsfloat wy,
			ifsfloat wz, ifsfloat ra, ifsfloat rx, ifsfloat ry, ifsfloat rz,
			int func) {
		X = x;
		Y = y;
		Z = z;
		Wx = wx;
		Wy = wy;
		Wz = wz;
		Ra = ra;
		Rx = rx;
		Ry = ry;
		Rz = rz;
		this.func = func;
	}

	this(Stream s) {
		s.readf(&X_, &Y_, &Z_, &Wx_, &Wy_, &Wz_, &Ra_, &Rx_, &Ry_, &Rz_, &func);
	}

	void toStream(Stream s) {
		s.writefln("%s %s %s %s %s %s %s %s %s %s %s", X_, Y_, Z_, Wx_, Wy_,
				Wz_, Ra_, Rx_, Ry_, Rz_, func);
	}

	void toStreamNice(Stream s) {
		s.writefln("--(%s %s %s) (%s %s %s) [%s %s %s %s] . %s --", X_, Y_, Z_,
				Wx_, Wy_, Wz_, Ra_, Rx_, Ry_, Rz_, func);
	}

	public void draw(ifsfloat r, ifsfloat g, ifsfloat b) {

		ifsfloat[4][4] rot = void;

		void transform(ifsfloat xx, ifsfloat yy, ifsfloat zz,
				ref ifsfloat[3] point) {

			MakeRotationMatrix(this.Ra, this.Rx, this.Ry, this.Rz, rot);

			xx -= X_;
			yy -= Y_;
			zz -= Z_;

			transformPoint(xx, yy, zz, rot);

			point[0] = xx + X_;
			point[1] = yy + Y_;
			point[2] = zz + Z_;
		}

		ifsfloat[3][8] tocke = void;
		transform(X, Y, Z, tocke[0]);
		transform(X + Wx, Y, Z, tocke[1]);
		transform(X + Wx, Y, Z + Wz, tocke[2]);
		transform(X, Y, Z + Wz, tocke[3]);
		transform(X, Y + Wy, Z, tocke[4]);
		transform(X + Wx, Y + Wy, Z, tocke[5]);
		transform(X + Wx, Y + Wy, Z + Wz, tocke[6]);
		transform(X, Y + Wy, Z + Wz, tocke[7]);

		glColor3f(r, g, b);
		glBegin(GL_LINE_LOOP);
		glVertex3f(tocke[0][0], tocke[0][1], tocke[0][2]);
		glVertex3f(tocke[1][0], tocke[1][1], tocke[1][2]);
		glVertex3f(tocke[2][0], tocke[2][1], tocke[2][2]);
		glVertex3f(tocke[3][0], tocke[3][1], tocke[3][2]);
		glEnd();
		glBegin(GL_LINE_LOOP);
		glVertex3f(tocke[4][0], tocke[4][1], tocke[4][2]);
		glVertex3f(tocke[5][0], tocke[5][1], tocke[5][2]);
		glVertex3f(tocke[6][0], tocke[6][1], tocke[6][2]);
		glVertex3f(tocke[7][0], tocke[7][1], tocke[7][2]);
		glEnd();
		glBegin(GL_LINES);
		for(int i = 0; i < 4; i++) {
			glVertex3f(tocke[0 + i][0], tocke[0 + i][1], tocke[0 + i][2]);
			glVertex3f(tocke[4 + i][0], tocke[4 + i][1], tocke[4 + i][2]);
		}
		glEnd();
		version(draw_transformation_star_point) {
			glPointSize(5);
			glBegin(GL_POINTS);
			glColor3f(1, 0, 0);
			glVertex3f(tocke[0][0], tocke[0][1], tocke[0][2]);
			glEnd();
		}
	}

	public void transformPoint(ref ifsfloat x, ref ifsfloat y, ref ifsfloat z) {
		transformPoint(x, y, z, matrix_from2biUnit);
		Transformation.applyFunction(x, y, z, this.func);
		transformPoint(x, y, z, matrix_biUnit2This);
	}

	static void applyFunction(ref ifsfloat x, ref ifsfloat y, ref ifsfloat z,
			int f1) {
		if(f1 == 0)
			return;
		ifsfloat r = sqrt(x * x + y * y);
		ifsfloat thetayx = atan(y / x);
		ifsfloat theta = atan(y / x);
		ifsfloat thetazy = atan(z / y);
		ifsfloat thetaxz = atan(x / z);
		switch(f1) {
			case 0:
			//linear
			break;
			case 1:
				//sinusoidal
				x = sin(x);
				y = sin(y);
			break;
			case 2:
				//spherical
				x = x / (r * r);
				y = y / (r * r);
			break;
			case 3:
				//swirl
				x = r * cos(theta + r);
				y = r * sin(theta + r);
			break;
			case 4:
				//horseshoe
				x = r * cos(2 * theta);
				y = r * sin(2 * theta);
			break;
			case 5:
				//polar
				x = theta / PI;
				y = r - 1;
			break;
			case 6:
				//handkerchief
				x = r * sin(theta + r);
				y = r * cos(theta - r);
			break;
			case 7:
				//heart
				x = r * sin(theta * r);
				y = -r * cos(theta * r);
			break;
			case 8:
				//disc
				x = theta * sin(PI * r) / PI;
				y = theta * cos(PI * r) / PI;
			break;
			case 9:
				//spiral
				x = (cos(theta) + sin(r)) / r;
				y = (sin(theta) - cos(r)) / r;
			break;
			case 10:
				//hyperbolic
				x = sin(theta) / r;
				y = cos(theta) * r;
			break;
			case 11:
				//diamond
				x = sin(theta) * cos(r);
				y = cos(theta) * sin(r);
			break;
			case 12:
				//ex
				x = r * pow(sin(theta + r), 3);
				y = r * pow(cos(theta - r), 3);
			break;
			case 13:
				//julia
				float omega;
				int broj = std.random.uniform(0, 100);
				if(broj < 50)
					omega = 0;
				else
					omega = PI;
				x = sqrt(r) * cos(theta / 2 + omega);
				y = sqrt(r) * sin(theta / 2 + omega);
			break;
			case 14:
				//fisheye
				x = 2 * r * x / (r + 1);
				y = 2 * r + y / (r + 1);
			break;
			case 15:
				//square
				x = x * x;
				y = y * y;
			break;
			case 16:
				//1/(x+yi)
				ifsfloat xtemp = x, ytemp = y;
				ifsfloat naz = xtemp * xtemp + ytemp * ytemp;
				x = xtemp / naz;
				y = -ytemp / naz;
			break;
			case 17:
				//x,y,z, swap
				ifsfloat temp = x;
				x = y;
				y = z;
				z = temp;
			break;
			case 18:
				//1/(x+yi)
				ifsfloat naz = x * x + y * y + z * z;
				x = x / naz;
				y = -y / naz;
				z = z / naz;
			break;
			default:
			break;
		}
	}

	static void transformPoint(ref ifsfloat x, ref ifsfloat y, ref ifsfloat z,
			ref ifsfloat[4][4] m) {
		ifsfloat x2, y2, z2, h2;

		x2 = m[0][0] * x + m[0][1] * y + m[0][2] * z + m[0][3] * 1;
		y2 = m[1][0] * x + m[1][1] * y + m[1][2] * z + m[1][3] * 1;
		z2 = m[2][0] * x + m[2][1] * y + m[2][2] * z + m[2][3] * 1;
		h2 = m[3][0] * x + m[3][1] * y + m[3][2] * z + m[3][3] * 1;

		x = x2 / h2;
		y = y2 / h2;
		z = z2 / h2;
	}

	//need: transform this->biUnit, biUnit->from
	public void CalculateTransformationMatrix2(Transformation from) {
		biUnit.CalculateTransformationMatrix(from, matrix_from2biUnit);
		this.CalculateTransformationMatrix(biUnit, matrix_biUnit2This);
	}

	//transform from 'from' to 'this'
	private void CalculateTransformationMatrix(Transformation from,
			ref ifsfloat[4][4] mat) {
		//		debug
		//			writefln("Calculating transformation matrix:");
		Transformation to = this;
		ifsfloat[4][4] M1 = [
			[1, 0, 0, -from.X],
			[0, 1, 0, -from.Y],
			[0, 0, 1, -from.Z],
			[0, 0, 0, 1]
		];
		ifsfloat[4][4] M2;
		MakeRotationMatrix(-from.Ra, from.Rx, from.Ry, from.Rz, M2);
		ifsfloat[4][4] M3 = [
			[to.Wx / from.Wx, 0, 0, 0],
			[0, to.Wy / from.Wy, 0, 0],
			[0, 0, to.Wz / from.Wz, 0],
			[0, 0, 0, 1]
		];
		ifsfloat[4][4] M4;
		MakeRotationMatrix(to.Ra, to.Rx, to.Ry, to.Rz, M4);
		ifsfloat[4][4] M5 = [
			[1, 0, 0, to.X],
			[0, 1, 0, to.Y],
			[0, 0, 1, to.Z],
			[0, 0, 0, 1]
		];

		ifsfloat[4][4] temp;

		Mul4Matrix(M5, M4, temp);
		Mul4Matrix(temp, M3, mat);
		Mul4Matrix(mat, M2, temp);
		Mul4Matrix(temp, M1, mat);

		//		debug
		//			writeln(matrix);

	}

	void Mul4Matrix(ifsfloat[4][4] a, ifsfloat[4][4] b, ref ifsfloat[4][4] c) {
		ifsfloat sum;
		for(int row = 0; row < 4; row++) {
			for(int col = 0; col < 4; col++) {
				sum = 0;

				for(int i = 0; i < 4; i++) {
					sum += a[row][i] * b[i][col];
				}

				c[row][col] = sum;
			}
		}
	}

	public static void MakeRotationMatrix(ifsfloat ra, ifsfloat rx,
			ifsfloat ry, ifsfloat rz, ref ifsfloat[4][4] mat) {
		ifsfloat w = cast(ifsfloat) cos(ra / 2);
		ifsfloat x = rx * cast(ifsfloat) sin(ra / 2);
		ifsfloat y = ry * cast(ifsfloat) sin(ra / 2);
		ifsfloat z = rz * cast(ifsfloat) sin(ra / 2);

		ifsfloat ww = w * w, xx = x * x, yy = y * y, zz = z * z;
		//row 0
		mat[0][0] = ww + xx - yy - zz;
		mat[0][1] = 2 * x * y + 2 * w * z;
		mat[0][2] = 2 * x * z - 2 * w * y;
		mat[0][3] = 0;
		//row 1
		mat[1][0] = 2 * x * y - 2 * w * z;
		mat[1][1] = ww - xx + yy - zz;
		mat[1][2] = 2 * y * z + 2 * w * x;
		mat[1][3] = 0;
		//row 2
		mat[2][0] = 2 * x * z + 2 * w * y;
		mat[2][1] = 2 * y * z - 2 * w * x;
		mat[2][2] = ww - xx - yy + zz;
		mat[2][3] = 0;
		//row 3
		mat[3][0] = 0;
		mat[3][1] = 0;
		mat[3][2] = 0;
		mat[3][3] = ww + xx + yy + zz;
	}

	ifsfloat area() {
		return Wx_ * Wy_ * Wz_;
	}

	ifsfloat X() {
		return X_;
	}

	ifsfloat X(ifsfloat a) {
		X_ = a;
		return X_;
	}

	ifsfloat Y() {
		return Y_;
	}

	ifsfloat Y(ifsfloat a) {
		Y_ = a;
		return Y_;
	}

	ifsfloat Z() {
		return Z_;
	}

	ifsfloat Z(ifsfloat a) {
		Z_ = a;
		return Z_;
	}

	ifsfloat Wx() {
		return Wx_;
	}

	ifsfloat Wx(ifsfloat a) {
		Wx_ = a;
		return Wx_;
	}

	ifsfloat Wy() {
		return Wy_;
	}

	ifsfloat Wy(ifsfloat a) {
		Wy_ = a;
		return Wy_;
	}

	ifsfloat Wz() {
		return Wz_;
	}

	ifsfloat Wz(ifsfloat a) {
		Wz_ = a;
		return Wz_;
	}

	ifsfloat Ra() {
		return Ra_;
	}

	ifsfloat Ra(ifsfloat a) {
		Ra_ = a;
		return Ra_;
	}

	ifsfloat Rx() {
		return Rx_;
	}

	ifsfloat Rx(ifsfloat a) {
		Rx_ = a;
		return Rx_;
	}

	ifsfloat Ry() {
		return Ry_;
	}

	ifsfloat Ry(ifsfloat a) {
		Ry_ = a;
		return Ry_;
	}

	ifsfloat Rz() {
		return Rz_;
	}

	ifsfloat Rz(ifsfloat a) {
		Rz_ = a;
		return Rz_;
	}

	package {
		ifsfloat X_, Y_, Z_, Wx_, Wy_, Wz_;
		ifsfloat Ra_, Rx_, Ry_, Rz_;
		int func;
		ifsfloat[4][4] matrix_from2biUnit;
		ifsfloat[4][4] matrix_biUnit2This;
		static Transformation biUnit;
		static const int numberOfFunc = 19;
	}

	static this() {
		biUnit = new Transformation(-1, -1, -1, 2, 2, 2);
	}
}