// Adapted from https://github.com/microsoft/terminal/blob/1283c0f5b99a2961673249fa77c6b986efb5086c/src/renderer/atlas/dwrite.hlsl
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

float color_brightness(float3 color) {
    // REC. 601 luminance coefficients for perceived brightness
    return dot(color, float3(0.30f, 0.59f, 0.11f));
}

float light_on_dark_contrast(float enhancedContrast, float3 color) {
    float brightness = color_brightness(color);
    float multiplier = saturate(4.0f * (0.75f - brightness));
    return enhancedContrast * multiplier;
}

float enhance_contrast(float alpha, float k) {
    return alpha * (k + 1.0f) / (alpha * k + 1.0f);
}

float3 enhance_contrast3(float3 alpha, float k) {
    return alpha * (k + 1.0f) / (alpha * k + 1.0f);
}

float apply_alpha_correction(float a, float b, float4 g) {
    float brightness_adjustment = g.x * b + g.y;
    float correction = brightness_adjustment * a + (g.z * b + g.w);
    return a + a * (1.0f - a) * correction;
}

float3 apply_alpha_correction3(float3 a, float3 b, float4 g) {
    float3 brightness_adjustment = g.x * b + g.y;
    float3 correction = brightness_adjustment * a + (g.z * b + g.w);
    return a + a * (1.0f - a) * correction;
}

// Windows Terminal scales the enhanced contrast down to zero for light colors
// (light_on_dark_contrast). Glyphs and icons apply it at every brightness, so
// light-on-dark text keeps the stroke weight of dark-on-light text.
float apply_contrast_and_gamma_correction(float sample, float3 color, float enhanced_contrast, float4 gamma_ratios) {
    float brightness = color_brightness(color);

    float contrasted = enhance_contrast(sample, enhanced_contrast);
    return apply_alpha_correction(contrasted, brightness, gamma_ratios);
}

float3 apply_contrast_and_gamma_correction3(float3 sample, float3 color, float enhanced_contrast, float4 gamma_ratios) {
    float3 contrasted = enhance_contrast3(sample, enhanced_contrast);
    return apply_alpha_correction3(contrasted, color, gamma_ratios);
}
