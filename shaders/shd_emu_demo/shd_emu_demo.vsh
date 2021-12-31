attribute vec3 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;
attribute vec4 in_Colour;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void CommonPointLightEvaluate(int i, inout vec4 finalColor, vec3 worldPosition, vec3 worldNormal);

void CommonPointLightEvaluate(inout vec4 finalColor, in vec3 worldPosition, in vec3 worldNormal, in vec3 lightPosition, float range) {
    vec3 lightDir = worldPosition - lightPosition;
    float dist = length(lightDir);
    float att = pow(clamp((1.0 - dist * dist / (range * range)), 0.0, 1.0), 2.0);
    lightDir /= dist;
    finalColor += vec4(max(0.0, -dot(worldNormal, lightDir)) * att);
}

void main() {
    vec3 worldPosition = vec3(gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1));
    vec3 worldNormal = normalize(gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0)).xyz;
    
    vec4 vertexColor = vec4(0.25, 0.25, 0.25, 1);
    CommonPointLightEvaluate(vertexColor, worldPosition, worldNormal, vec3(48., 0., 32.), 200.);
    CommonPointLightEvaluate(vertexColor, worldPosition, worldNormal, vec3(-16., -32., 80.), 96.);
    v_vTexcoord = in_TextureCoord;
    v_vColour = in_Colour * min(vertexColor, vec4(1));
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1);
}