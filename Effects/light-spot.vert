#version 120

uniform mat4 aircraft_model_matrix;
uniform mat4 osg_ViewMatrix;
varying vec4 ecPosition;
varying vec4 transformed_position;
/*varying vec4 transformed_direction;*/
varying vec3 normal;


void main() 
{
	
	transformed_position =   osg_ViewMatrix * aircraft_model_matrix * vec4(-3.64142, 0.0, 0.5, 1.0);
	/*transformed_direction = aircraft_model_matrix * normalize(vec4(1.0, -0.3, 1.0, 0.0));*/
	
	normal = normalize(gl_NormalMatrix * gl_Normal);
    ecPosition = gl_ModelViewMatrix * gl_Vertex;
    gl_Position = ftransform();
}
