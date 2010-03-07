uniform vec3 CameraPosition;
uniform float FadeOffDist;
varying float Distance; 

void main()
{ 
//	vec4 v = vec4(gl_Vertex);
//	float dx = v.x - CameraPosition.x;
//	float dy = v.y - CameraPosition.y;
//	float dz = v.z - CameraPosition.z;
//	Distance = clamp((dx*dx)+(dy*dy)+(dz*dz), 0.0, FadeOffDist);

	gl_FrontColor = gl_Color; // * (1-Distance/FadeOffDist);
	gl_FrontColor.a = 0.5;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}