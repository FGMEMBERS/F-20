#version 120

#extension ARB_shader_storage_buffer_object: enable


uniform vec4  light_position;
uniform vec4  light_direction;
vec3 transformed_direction;


layout (std140, binding = 0) buffer lightData
{
	vec3 transformed_position;
	vec3 transformed_direction;
};


void main() 
{

	//lightData.transformed_position = gl_ModelViewMatrix*light_position;
	lightData.transformed_direction = normalize(vec3 (gl_ModelViewMatrix * vec4(1.0, -0.3, -1.0, 0.0)));

	//transformed_direction = normalize(vec3 (gl_ModelViewMatrix * vec4(1.0, -0.3, -1.0, 0.0)));
    gl_Position = ftransform();
}
