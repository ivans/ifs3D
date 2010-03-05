#version 120 

void main()
{
	vec4 myOutputColor = gl_Color;
	//myOutputColor.a = 0.03;
	gl_FragColor = myOutputColor;
}