module ivan.ifs3d.transformation;

private 
{
  import std.math;
  import std.stream;
  import std.stdio;
  import glfw;
}

T[] array(T)(T[] a ...)
{
  return a.dup;
}

class Transformation
{
  void initMatrix()
  {
    matrix_from2biUnit.length = 4;
    foreach(ref x; matrix_from2biUnit)x.length = 4;
    
    matrix_biUnit2This.length = 4;
    foreach(ref x; matrix_biUnit2This)x.length = 4;
  }

	this(real x,real y,real z)
	{
    this(x,y,z,1,1,1);
	}

	this(real x,real y,real z, real wx, real wy, real wz)
	{
    this(x,y,z,wx,wy,wz,0,1,0,0);
	}

	this(real x,real y,real z, real wx, real wy, real wz, real ra, real rx, real ry, real rz)
	{
	  this(x,y,z,wx,wy,wz,ra,rx,ry,rz,0);
	}

  this(real x,real y,real z, real wx, real wy, real wz,
       real ra, real rx, real ry, real rz, int func)
  {
    initMatrix();
		X = x; Y = y; Z = z;
		Wx = wx; Wy = wy; Wz = wz;
    Ra = ra; Rx = rx; Ry = ry; Rz = rz;
    this.func = func;
  }

	this(Stream s)
	{
    initMatrix();
    s.readf(&X_,&Y_,&Z_,&Wx_,&Wy_,&Wz_,&Ra_,&Rx_,&Ry_,&Rz_,&func);
	}

  void toStream(Stream s)
  {
    s.writefln("%s %s %s %s %s %s %s %s %s %s %s", X_, Y_, Z_, Wx_, Wy_, Wz_, Ra_, Rx_, Ry_, Rz_, func);
  }
  
  void toStreamNice(Stream s)
  {
    s.writefln("--(%s %s %s) (%s %s %s) [%s %s %s %s] . %s --", X_, Y_, Z_, Wx_, Wy_, Wz_, Ra_, Rx_, Ry_, Rz_, func);
  }

  public void draw(real r, real g, real b)
  {
    real[] transform(real xx, real yy, real zz)
    {
      real[][] rot = MakeRotationMatrix(this.Ra, this.Rx, this.Ry, this.Rz);

      xx -= X_;
      yy -= Y_;
      zz -= Z_;

      transformPoint(xx, yy, zz, rot);
      
      return array!(real)(xx + X_, yy + Y_, zz + Z_);
    }

    real[][] tocke =
    array!(real[])(
      transform(X,Y,Z),
      transform(X+Wx,Y,Z),
      transform(X+Wx,Y,Z+Wz),
      transform(X,Y,Z+Wz),
      transform(X,Y+Wy,Z),
      transform(X+Wx,Y+Wy,Z),
      transform(X+Wx,Y+Wy,Z+Wz),
      transform(X,Y+Wy,Z+Wz)
    );

    glColor3f(r,g,b);
    glLineWidth(1);
    glBegin(GL_LINE_LOOP);
      glVertex3f(tocke[0][0],tocke[0][1],tocke[0][2]);
      glVertex3f(tocke[1][0],tocke[1][1],tocke[1][2]);
      glVertex3f(tocke[2][0],tocke[2][1],tocke[2][2]);
      glVertex3f(tocke[3][0],tocke[3][1],tocke[3][2]);
    glEnd();
    glBegin(GL_LINE_LOOP);
      glVertex3f(tocke[4][0],tocke[4][1],tocke[4][2]);
      glVertex3f(tocke[5][0],tocke[5][1],tocke[5][2]);
      glVertex3f(tocke[6][0],tocke[6][1],tocke[6][2]);
      glVertex3f(tocke[7][0],tocke[7][1],tocke[7][2]);
    glEnd();
    glBegin(GL_LINES);
      for(int i=0; i<4; i++)
      {
        glVertex3f(tocke[0+i][0],tocke[0+i][1],tocke[0+i][2]);
        glVertex3f(tocke[4+i][0],tocke[4+i][1],tocke[4+i][2]);
      }
    glEnd();
    glBegin(GL_POINTS);
    glColor3f(1,0,0);
      glVertex3f(tocke[0][0],tocke[0][1],tocke[0][2]);
    glEnd();
  }

  real[] transformPointToArray(real x, real y, real z)
  {
    transformPoint(x,y,z);
    real[] a = array!(real)(x,y,z);
    return a;
  }
  
  public void transformPoint(ref real x, ref real y, ref real z)
  {
    transformPoint(x, y, z, matrix_from2biUnit);
    Transformation.applyFunction(x,y,z,this.func);
    transformPoint(x, y, z, matrix_biUnit2This);
  }

  static void applyFunction(ref real x, ref real y, ref real z, int f1)
  {
    if(f1 == 0) return;
    real r = sqrt(x*x+y*y);
    real thetayx = atan(y/x);
    real theta = atan(y/x);
    real thetazy = atan(z/y);
    real thetaxz = atan(x/z);
    switch(f1)
    {
      case 0: //linear
        break;
      case 1: //sinusoidal
        x = sin(x);
        y = sin(y);
        break;
      case 2: //spherical
        x = x/(r*r);
        y = y/(r*r);
        break;
      case 3: //swirl
        x = r*cos(theta+r);
        y = r*sin(theta+r);
        break;
      case 4: //horseshoe
        x = r*cos(2*theta);
        y = r*sin(2*theta);
        break;
      case 5: //polar
        x = theta/PI;
        y = r-1;
        break;
      case 6: //handkerchief
        x = r*sin(theta+r);
        y = r*cos(theta-r);
        break;
      case 7: //heart
        x = r*sin(theta*r);
        y = -r*cos(theta*r);
        break;
      case 8: //disc
        x = theta*sin(PI*r)/PI;
        y = theta*cos(PI*r)/PI;
        break;
      case 9: //spiral
        x = (cos(theta)+sin(r))/r;
        y = (sin(theta)-cos(r))/r;
        break;
      case 10: //hyperbolic
        x = sin(theta)/r;
        y = cos(theta)*r;
        break;
      case 11: //diamond
        x = sin(theta)*cos(r);
        y = cos(theta)*sin(r);
        break;
      case 12: //ex
        x = r*pow(sin(theta+r),3);
        y = r*pow(cos(theta-r),3);
        break;
      case 13: //julia
        float omega;
        int broj = std.random.uniform(0, 100);
        if(broj<50)omega = 0;
        else omega = PI;
        x = sqrt(r)*cos(theta/2+omega);
        y = sqrt(r)*sin(theta/2+omega);
        break;
      case 14: //fisheye
        x = 2*r*x/(r+1);
        y = 2*r+y/(r+1);
        break;
      case 15: //square
        x = x*x;
        y = y*y;
        break;
      case 16: //1/(x+yi)
        real xtemp = x, ytemp = y;
        real naz = xtemp*xtemp+ytemp*ytemp;
        x = xtemp/naz;
        y = -ytemp/naz;
        break;
      case 17: //x,y,z, swap
        real temp = x;
        x = y;
        y = z;
        z = temp;
        break;
      case 18: //1/(x+yi)
        real naz = x*x + y*y + z*z;
        x = x / naz;
        y = -y / naz;
        z = z / naz;
        break;        
      default: break;
    }
  }
  
  static void transformPoint(ref real x, ref real y, ref real z, real[][] m)
  {
    real x2, y2, z2, h2;

    x2 = m[0][0]*x + m[0][1]*y + m[0][2]*z + m[0][3]*1;
    y2 = m[1][0]*x + m[1][1]*y + m[1][2]*z + m[1][3]*1;
    z2 = m[2][0]*x + m[2][1]*y + m[2][2]*z + m[2][3]*1;
    h2 = m[3][0]*x + m[3][1]*y + m[3][2]*z + m[3][3]*1;

    x = x2/h2;
    y = y2/h2;
    z = z2/h2;
  }

  //need: transform this->biUnit, biUnit->from
  public void CalculateTransformationMatrix2(Transformation from)
  {
    matrix_from2biUnit = biUnit.CalculateTransformationMatrix(from);
    matrix_biUnit2This = this.CalculateTransformationMatrix(biUnit);
  }
  
  //transform from 'from' to 'this'
  private real[][] CalculateTransformationMatrix(Transformation from)
  {
    debug writefln("Calculating transformation matrix:");
    Transformation to = this;
    real[][] M1 = 
      array!(real[])(
        array!(real)(1,0,0,-from.X),
        array!(real)(0,1,0,-from.Y),
        array!(real)(0,0,1,-from.Z),
        array!(real)(0,0,0,1)
        );
    real[][] M2 = MakeRotationMatrix(-from.Ra, from.Rx, from.Ry, from.Rz);
    real[][] M3 = 
      array!(real[])(
        array!(real)(to.Wx/from.Wx,0,0,0),
        array!(real)(0,to.Wy/from.Wy,0,0),
        array!(real)(0,0,to.Wz/from.Wz,0),
        array!(real)(0,0,0,1)
        );
    real[][] M4 = MakeRotationMatrix(to.Ra, to.Rx, to.Ry, to.Rz);
    real[][] M5 = 
      array!(real[])(
        array!(real)(1,0,0,to.X),
        array!(real)(0,1,0,to.Y),
        array!(real)(0,0,1,to.Z),
        array!(real)(0,0,0,1)
        );

    real[][] temp, matrix;
    temp.length = 4;
    foreach(ref x; temp) x.length = 4;

    matrix.length = 4;
    foreach(ref x; matrix) x.length = 4;

    Mul4Matrix(M5, M4, temp);
    Mul4Matrix(temp, M3, matrix);
    Mul4Matrix(matrix, M2, temp);
    Mul4Matrix(temp, M1, matrix);
    
    debug writeln(matrix);
    
    return matrix;
  }

  void Mul4Matrix(real[][] a, real[][] b, real[][] c)
  {
    real sum;
    for(int row=0; row<4; row++)
    {
      for(int col=0; col<4; col++)
      {
        sum = 0;

        for(int i=0; i<4; i++)
        {
          sum += a[row][i] * b[i][col];
        }

        c[row][col] = sum;
      }
    }
  }
  
  public static real[][] MakeRotationMatrix(real ra, real rx, real ry, real rz)
  {
    real w = cast(real)cos(ra/2);
    real x = rx * cast(real)sin(ra/2);
    real y = ry * cast(real)sin(ra/2);
    real z = rz * cast(real)sin(ra/2);

    real sq(real x){return x*x;}
    
    real[][] M2 = 
      array!(real[])(
        array!(real)( 
          sq(w) + sq(x) - sq(y) - sq(z),
          2*x*y + 2*w*z,
          2*x*z - 2*w*y,
          0),
        array!(real)( 
          2*x*y - 2*w*z,
          sq(w) - sq(x) + sq(y) - sq(z),
          2*y*z + 2*w*x,
          0),
        array!(real)( 
          2*x*z + 2*w*y,
          2*y*z - 2*w*x,
          sq(w) - sq(x) - sq(y) + sq(z),
          0),
        array!(real)(0,0,0, sq(w) + sq(x) + sq(y) + sq(z))
      );
    
    return M2;
  }
  
  real area()
  {
    return Wx_ * Wy_ * Wz_;
  }
  
  real X(){return X_;} real X(real a){X_ = a; return X_;}
  real Y(){return Y_;} real Y(real a){Y_ = a; return Y_;}
  real Z(){return Z_;} real Z(real a){Z_ = a; return Z_;}
  real Wx(){return Wx_;} real Wx(real a){Wx_ = a; return Wx_;}
  real Wy(){return Wy_;} real Wy(real a){Wy_ = a; return Wy_;}
  real Wz(){return Wz_;} real Wz(real a){Wz_ = a; return Wz_;}
  real Ra(){return Ra_;} real Ra(real a){Ra_ = a; return Ra_;}
  real Rx(){return Rx_;} real Rx(real a){Rx_ = a; return Rx_;}
  real Ry(){return Ry_;} real Ry(real a){Ry_ = a; return Ry_;}
  real Rz(){return Rz_;} real Rz(real a){Rz_ = a; return Rz_;}

	package
	{
		real X_,Y_,Z_,Wx_,Wy_,Wz_;
		real Ra_, Rx_, Ry_, Rz_;
    int func;
    real[][] matrix_from2biUnit;
    real[][] matrix_biUnit2This;
    static Transformation biUnit;
    static const int numberOfFunc = 19;
  }
  static this()
  {
    biUnit = new Transformation(-1,-1,-1,2,2,2);
  }
}