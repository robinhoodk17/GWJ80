shader_type sky;
render_mode use_half_res_pass, use_debanding;

uniform vec4 baseColor : source_color = vec4(0.0, 0.64, 0.84, 1.0);
uniform vec4 horizonColor : source_color = vec4(0.36, 0.59, 0.86, 1.0);

uniform float horizonHeight : hint_range(-1.0, 1.0, 0.01) = -0.2;
uniform float rayleighCoefficient : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float mieCoefficient : hint_range(0.0, 1.0, 0.01);
uniform float mieEccentricity : hint_range(-1.0, 1.0, 0.01) = 0.8;

uniform float sunDiskScale: hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float sunSmoothing : hint_range(0.0, 1.0, 0.1) = 0.5;

uniform sampler2D cloudTexture;
uniform sampler2D cloudCoverageTexture;

// Calculate the total amount of light scattered by Rayleigh scattering for all lights
vec3 rayleighScattering(float cos_theta) {
	float rayleighSunPhase = 0.75 * (1.0 + cos_theta * cos_theta);
	vec3 rayleighColor = horizonColor.rgb * rayleighCoefficient * rayleighSunPhase;

	return rayleighColor;
}

// Calculate the total amount of light scattered by Mie scattering for all lights
vec3 mieScattering(float cos_theta, float g) {
	float mieSunPhase = ((1.0 - g * g) / (4.0 * PI)) * (1.0 + g * g - 2.0 * g * cos_theta) / pow(1.0 + g * g - 2.0 * g * cos_theta, 1.5);
	vec3 mieColor = horizonColor.rgb * mieCoefficient * mieSunPhase;

	return mieColor;
}

void sky() {
	// compute stereographic coordinates
	float theta = acos(dot(EYEDIR, vec3(0, 1, 0)));
	float phi = atan(EYEDIR.z, EYEDIR.x);
	float r = 2.0 * tan(theta / 2.0);
	vec2 stereographic = r * vec2(cos(phi), sin(phi));
	vec2 texCoords = vec2(0.5, 0.5) + stereographic * vec2(0.5, -0.5);

	float cos_theta = dot(EYEDIR, LIGHT0_DIRECTION);

	// Solar disk
	float sunDir = distance(EYEDIR, LIGHT0_DIRECTION);
	float sunPos = 1.0 - clamp(sunDir / sunDiskScale, 0.0, 1.0);
	float sunAngularDiameterCos = cos(sunPos * sunDiskScale);
	float sunAngularDiameterCos2 = cos(sunPos * sunDiskScale * sunSmoothing);
	float sunDisk = smoothstep(sunAngularDiameterCos, sunAngularDiameterCos2, cos_theta);
	vec4 sun = vec4(LIGHT0_COLOR * LIGHT0_ENERGY, sunDisk);

	vec3 totalScattering = mieScattering(cos_theta, mieEccentricity) + rayleighScattering(cos_theta);

	vec4 clouds = mix(texture(cloudTexture, texCoords), vec4(0), texture(cloudCoverageTexture, texCoords));
	float colorGradient = EYEDIR.y - horizonHeight;
	vec3 skyColor;
	skyColor = mix(horizonColor.rgb, baseColor.rgb, colorGradient);
	skyColor = mix(skyColor.rgb, sun.rgb, sun.a);
	skyColor = mix(skyColor.rgb, clouds.xyz, clouds.rgb);

	COLOR = skyColor + totalScattering;
}