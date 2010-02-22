module ivan.ifs3d.callback;

private
{
  import ivan.ifs3d.mousestate;
}

void delegate(int w, int h) windowResize;
void delegate(int pos) mouseWheel;
void delegate(int x, int y) mousePos;
void delegate(int button, int action) mouseButton;
void delegate(int key, int action) keyCallback;
void delegate(int character, int state) characterCallback;

extern(Windows) void windowResizeFunc(int w, int h)
{
  windowResize(w,h);
}

extern(Windows) void mouseWheelFunc(int pos)
{
  mouseWheel(pos);
}

extern(Windows) void mousePosFunc(int x, int y)
{
  mousePos(x,y);
}

extern(Windows) void mouseButtonFunc(int button, int action)
{
  mouseButton(button,action);
}

extern(Windows) void keyCallbackFunc(int key, int action)
{
  keyCallback(key,action);
}

extern(Windows) void characterCallbackFunc(int character, int state)
{
  characterCallback(character,state);
}