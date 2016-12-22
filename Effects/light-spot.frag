#version 120


uniform vec2 fg_BufferSize;
uniform vec3 fg_Planes;

uniform sampler2D depth_tex;
uniform sampler2D normal_tex;
uniform sampler2D color_tex;
uniform sampler2D spec_emis_tex;
uniform vec4 Ambient;
uniform vec4 Diffuse;
uniform vec4 Specular;
uniform vec3 Attenuation;
uniform float Exponent;
uniform float Cutoff;
uniform float CosCutoff;
uniform float Near;
uniform float Far;

/*
layout (std140, binding = 0) buffer lightData
{
	vec3 transformed_position;
	vec3 transformed_direction;
};
*/

varying vec3 normal;
varying vec4 transformed_position;
in vec3 transformed_direction;
varying vec4 ecPosition;

void main()
{
   vec3 n = vec3 (1.0, 0.0, 0.0);
   vec3 lightDir = vec3 (-1.0, 0.0, 0.0);;
   float NdotL = 0.5;
   vec4 color = vec4 (0.5, 0.5, 0.5, 1.0);
   //vec4 color = vec4 (1.0, 0.0, 0.5, 1.0);
   float att, dist;
    
    n = normalize(normal);
    
    lightDir = vec3(transformed_position - ecPosition);
   
    //lightDir =vec3 (-1, -1, 0);
     
    dist = length(lightDir);
    
    NdotL = max(dot(n, normalize(lightDir)),0.0);
    
    //NdotL = 0.8;
         
    if (NdotL > 0.0) {
     
        //att = 1.0 / (0.1 * dist);
        att=1.0;
        color += att * (vec4(1.0, 0.0, 0.5, 1.0) * NdotL);
     
    }
    /*
    if (NdotL > 1.0)
     color = vec4 (0.0, 0.5, 0.5, 1.0);
    else if (NdotL > 0.75)
     color = vec4 (0.0, 0.0, 0.5, 1.0);
    else if (NdotL > 0.5)
     color = vec4 (0.0, 0.5, 0.0, 1.0);    
    else if (NdotL > 0.25)
     color = vec4 (0.5, 0.0, 0.0, 1.0);         
    else if (NdotL > 0)
     color = vec4 (0.5, 0.0, 0.5, 1.0);         
    else 
     color = vec4 (0.5, 0.5, 0.0, 1.0);
    */
     
    gl_FragColor = color;
    
}

