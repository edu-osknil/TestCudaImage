#include <iostream>
#include "Color.cu"
#include "Io.cu"
#include <opencv2/opencv.hpp>

__global__
void OverlayGPUImage(unsigned char* baseImage, int baseCols, int baseRows, int BaseStep, unsigned char baseChannels,
    unsigned char* overlay, int overlayCols, int overlayRows, int overlayStep, unsigned char overlayChannels);

extern "C" void OverlayImage(cv::Mat& baseImage){
    cv::Mat overlay = Inputs::ImportImage();

    unsigned char* baseImagePointer = nullptr;
    size_t baseImageSize = baseImage.step * baseImage.rows;
    cudaMalloc(&baseImagePointer, baseImageSize);
    cudaMemcpy(baseImagePointer, baseImage.data, baseImageSize, cudaMemcpyHostToDevice);

    unsigned char* overlayImagePointer = nullptr;
    size_t overlayImageSize = overlay.step * overlay.rows;
    cudaMalloc(&overlayImagePointer, overlayImageSize);
    cudaMemcpy(overlayImagePointer, overlay.data, overlayImageSize, cudaMemcpyHostToDevice);

    dim3 block(16,16);
    dim3 grid(baseImage.cols / block.x + 1, baseImage.cols / block.y + 1);
    OverlayGPUImage<<<grid, block>>>(
        baseImagePointer,
        baseImage.cols,
        baseImage.rows,
        baseImage.step,
        baseImage.channels(),
        overlayImagePointer,
        overlay.cols,
        overlay.rows,
        overlay.step,
        overlay.channels()
    );

    cudaFree(overlayImagePointer);
}

__global__
void OverlayGPUImage(unsigned char* baseImage, int baseCols, int baseRows, int BaseStep, unsigned char baseChannels,
    unsigned char* overlay, int overlayCols, int overlayRows, int overlayStep, unsigned char overlayChannels){
    int idX = threadIdx.x + blockIdx.x * blockDim.x;
    int idY = threadIdx.y + blockIdx.y * blockDim.y;

    unsigned char* pixel = baseImage + (idX + idY * baseCols) * baseChannels;
    unsigned char* overlayPixel = overlay + (idX + idY * overlayCols) * overlayChannels;

    Color pixelColor = Color(pixel, overlayPixel, overlayChannels == 4);
    pixelColor.SetPixel(pixel);
}