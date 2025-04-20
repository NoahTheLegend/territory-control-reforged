//blur shader
//gingerbeard got this from chatgpt LOL

uniform sampler2D baseMap;
uniform float blur_strength = 1.0;

void main()
{
    vec2 tex_offset = 1.0 / textureSize(baseMap, 0) * blur_strength;
    vec3 color = vec3(0.0);
    float weight_sum = 0.0;

    // Gaussian blur with a 5x5 kernel
    for (int x = -2; x <= 2; x++)
    {
        for (int y = -2; y <= 2; y++)
        {
            // Gaussian weight for blur smoothness
            float weight = exp(-(x * x + y * y) / (2.0 * blur_strength * blur_strength));
            vec2 offset = vec2(float(x), float(y)) * tex_offset;

            color += texture(baseMap, gl_TexCoord[0] + offset).rgb * weight;
            weight_sum += weight;
        }
    }

    color /= weight_sum; // Normalize the final color
    gl_FragColor = vec4(color, 1.0);
}
