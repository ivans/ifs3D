void main()
{ 
	vec4 v = vec4(gl_Vertex);
	//v.z = v.z + sin(v.x*v.x + v.y*v.y)/10.0;
	gl_Position = gl_ModelViewProjectionMatrix * v;
	gl_FrontColor = gl_Color;
}