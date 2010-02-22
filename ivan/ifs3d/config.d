module ivan.ifs3d.config;

private
{
  import std.stream;
  import std.file;
  import std.conv;
  import std.stdio;
  import ivan.ifs3d.callback;
  import ivan.ifs3d.global;
  alias ivan.ifs3d.global global;
  
  import glfw;
  import freeimage;
}

class Config
{
  this(string fileName)
  {
    intParams["fileCounter"] = 0;
    intParams["iterationsWhenSaving"] = 10000;
    intParams["depthBits"] = 32;
    intParams["drawTransAndAxes"] = 1;
    intParams["resX"] = 800;
    intParams["resY"] = 600;
    intParams["picResX"] = 1024*2;
    intParams["picResY"] = 768*2;
    intParams["picSmallX"] = 1024;
    intParams["picSmallY"] = 768;

    if(std.file.exists(fileName))
    {
      debug global.o.writefln("Config file found, loading...");
      loadConfigFile(fileName);
    }
    else
    {
      debug global.o.writefln("Config file not found, creating...");
      saveConfigFile(fileName);
    }

    intParams["adjContrast"] = 0;
    intParams["adjBrightness"] = 0;
    intParams["adjGamma"] = -80;
    
  }

  void saveConfigFile(string fileName)
  {
    std.stream.File f = new std.stream.File(fileName, FileMode.OutNew);
    printParams(f);
    f.close();
    return;
  }

  void loadConfigFile(string fileName)
  {
    char[] key;
    char[] value;
    std.stream.File f = new std.stream.File(fileName,FileMode.In);
    while( f.readf(&key, &value) != 0) {
      intParams[key.dup] = std.conv.to!(int)(value);
    }
    printParams(global.o);
    f.close();
    return;
  }

  void printParams(Stream s) {
    foreach(key, value; intParams) {
      if(key != "") {
        s.writefln("%s %d", key, value);
      }
    }
  }
  
  void clrscr()
  {
    clearscreen = 2;
  }

  void InitFreeImage()
  {
  	FreeImage_Initialise();
  	auto freeImgVersion = FreeImage_GetVersion();
  	auto freeImgCopyright = FreeImage_GetCopyrightMessage();
  	
  	writefln("%s\n%s", freeImgVersion, freeImgCopyright);
  }

  void initGlfw()
  {
    debug global.o.writefln("Init GLFW and get current desktop mode...");
    InitFreeImage();
    glfwInit();
    glfwGetDesktopMode(&desktopMode);
  }

  void registerCallbacks()
  {
    debug global.o.writefln("register callbacks...");
    glfwSetWindowSizeCallback(cast(GLFWwindowsizefun)&windowResizeFunc);

    glfwSetKeyCallback(cast(GLFWkeyfun)&keyCallbackFunc);
    glfwSetCharCallback(cast(GLFWcharfun)&characterCallbackFunc);

    glfwSetMouseWheel(0);

    glfwSetMousePosCallback(cast(GLFWmouseposfun)&mousePosFunc);
    glfwSetMouseButtonCallback(cast(GLFWmousebuttonfun)&mouseButtonFunc);
    glfwSetMouseWheelCallback(cast(GLFWmousewheelfun)&mouseWheelFunc);
  }

  void setPerspective()
  {
  	glMatrixMode(GL_PROJECTION);
  	glLoadIdentity();

  	gluPerspective(45,cast(GLfloat)conf.getIntParam("resX")/cast(GLfloat)conf.getIntParam("resY"),0.1f,10000.0f);
  	gluLookAt( 
      scene.cameraPosition.x, scene.cameraPosition.y, scene.cameraPosition.z, 
      scene.cameraLookAt.x, scene.cameraLookAt.y, scene.cameraLookAt.z, 
      0.0, 1.0, 0.0);
  }

  void setOrtho()
  {
  	glMatrixMode(GL_PROJECTION);
  	glLoadIdentity();
  	glOrtho(0, global.conf.getIntParam("resX"), global.conf.getIntParam("resY"), 0, 0, 1.0);
  }

  void setModelView()
  {
    glMatrixMode(GL_MODELVIEW);
  	glLoadIdentity();
  }
  
  void showWindow()
  {
    if( !glfwOpenWindow( getIntParam("resX"), getIntParam("resY"), 0,0,0,0, getIntParam("depthBits"),0, currentWindowType ) )
    {
      glfwTerminate();
      return;
    }
    glfwEnable( GLFW_MOUSE_CURSOR );

    glfwEnable( GLFW_STICKY_KEYS );
    glfwEnable( GLFW_KEY_REPEAT );
    glfwSwapInterval( 0 );

    glClearColor(bgColor[0], bgColor[1], bgColor[2], 0.0f);

    glPolygonMode(GL_FRONT, GL_FILL);
    glPolygonMode(GL_BACK, GL_LINE);

    glClearDepth(1.0f);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_POINT_SMOOTH);
    glDrawBuffer(GL_FRONT_AND_BACK);
  }

  void terminateGlfw()
  {
    debug global.o.writefln("Terminate GLFW...");
    glfwTerminate();
  }

  int nextFileCounter()
  {
    setIntParam("fileCounter", getIntParam("fileCounter")+1);
    saveConfigFile("ifs3d_init.txt");
    return getIntParam("fileCounter");
  }

  int getIntParam(string paramName) {
    if(!(paramName in intParams)) {
      throw new Exception("Int param " ~ paramName ~ " not found");
    }
    return intParams[paramName];
  }

  void setIntParam(string paramName, int value) {
    if(paramName == "")return;
    if(!(paramName in intParams)) {
      throw new Exception("Int param " ~ paramName ~ " not found");
    }
    intParams[paramName] = value;
  }
  
  int[char[]] intParams;
  char[char[]] stringParams;

  bool drawTransAndAxes = true;
  GLFWvidmode desktopMode;
  int currentWindowType = GLFW_WINDOW;
}