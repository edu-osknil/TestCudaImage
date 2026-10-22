#pragma once

class Color{
public:
    unsigned char b, g, r;

    __device__ __host__
    Color() {b = 0; g = 0; r = 0;}

    __device__ __host__
    Color(unsigned char blue, unsigned char green, unsigned char red){
        b = blue; g = green; r = red;
    }
    __device__
    Color(unsigned char* p1, unsigned char* p2, bool hasAlpha){
        b = hasAlpha ? p1[0] + p2[4] * (p2[0] - p1[0]) : p2[0];
        g = hasAlpha ? p1[1] + p2[4] * (p2[1] - p1[1]) : p2[1];
        r = hasAlpha ? p1[2] + p2[4] * (p2[2] - p1[2]) : p2[2];
    } 
    __device__
    void SetPixel(unsigned char* pixel) {
        pixel[0] = b; pixel[1] = g; pixel[2] = r;
    }
    __device__
    void LerpColor(unsigned char* pixelCol, float lerpStrength){
        b = b + lerpStrength * (pixelCol[0] - b);
        g = g + lerpStrength * (pixelCol[1] - g);
        r = r + lerpStrength * (pixelCol[2] - r);
    }
};