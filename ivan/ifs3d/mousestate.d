module ivan.ifs3d.mousestate;

class MouseState
{
  int X = 100, Y = 100;
  int XDelta = 0, YDelta = 0;
  bool Left = false, Middle = false, Right = false;
  bool LeftOld = false, MiddleOld = false, RightOld = false;
  int WheelPos = 0, WheelDelta = 0;
}
