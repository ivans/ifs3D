module ivan.ifs3d.point;

private import std.string;
private import std.math;
import ivan.ifs3d.types;

struct Point {
	ifsfloat x;
	ifsfloat y;
	ifsfloat z;

	static Point opCall(ifsfloat x, ifsfloat y, ifsfloat z) {
		Point t;
		t.x = x;
		t.y = y;
		t.z = z;
		return t;
	}

	Point dup() {
		return Point(x, y, z);
	}

	string toString() {
		return std.string.format("(%5s, %5s, %5s)", x, y, z);
	}

	static ifsfloat dist(Point t1, Point t2) {
		ifsfloat sq(ifsfloat x) {
			return x * x;
		}
		return sqrt(sq(t1.x - t2.x) + sq(t1.y - t2.y) + sq(t1.z - t2.z));
	}
}