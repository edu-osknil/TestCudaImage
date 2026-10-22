#include <iostream>
#include "Color.cu"
#include "Io.cu"
#include <opencv2/opencv.hpp>

__global__
void TintCudaImage(unsigned char* image, int cols, Color tintColor, float tintStrength, const char channels = 3);

extern "C" void TintImage(cv::Mat& image)
{
    Color tintColor = Inputs::GetColor();
    float strength = Inputs::GetNumber(0, 1, "Enter tint strength\n");

    size_t imageByteSize = image.step * image.rows;
    unsigned char* imagePointer = nullptr;
    cudaMalloc(&imagePointer, imageByteSize);
    cudaMemcpy(imagePointer, image.data, imageByteSize, cudaMemcpyHostToDevice);

    dim3 block(16, 16);
    dim3 grid(image.cols / block.x + 1, image.cols / block.y + 1);
    TintCudaImage<<<grid, block>>>(
        imagePointer,
        image.cols,
        tintColor,
        strength,
        image.channels()
    );
    cudaMemcpy(image.data, imagePointer, imageByteSize, cudaMemcpyDeviceToHost);
    cudaFree(imagePointer);
}

__global__
void TintCudaImage(unsigned char* image, int cols, Color tintColor, float tintStrength, const char channels){
    int idX = threadIdx.x + blockIdx.x * blockDim.x;
    int idY = threadIdx.y + blockIdx.y * blockDim.y;

    unsigned char* pixel = image + (idX + idY * cols) * channels;
    tintColor.LerpColor(pixel, 1-tintStrength);
    tintColor.SetPixel(pixel);
}