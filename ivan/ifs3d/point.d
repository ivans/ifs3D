module ivan.ifs3d.point;

private import std.string;
private import std.math;

struct Point {
	real x;
	real y;
	real z;

	static Point opCall(real x, real y, real z) {
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

	static real dist(Point t1, Point t2) {
		real sq(real x) {
			return x * x;
		}
		return sqrt(sq(t1.x - t2.x) + sq(t1.y - t2.y) + sq(t1.z - t2.z));
	}
}