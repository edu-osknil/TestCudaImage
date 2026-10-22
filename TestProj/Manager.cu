#include <opencv2/opencv.hpp>
#include <iostream>
#include "Io.cu"

cv::Mat CreateImage();

int main(){
    cv::Mat image = CreateImage();
    std::cout << "Write help to print commands" << std::endl;
    while (true){
        if (!Inputs::UpdateImage(image)){
            break;
        }
    }
    return 0;
}

cv::Mat CreateImage(){
    return cv::Mat::zeros(
        static_cast<unsigned int>(Inputs::GetNumber(0, 10000, "Enter the x dimension of the new image -> ")),
        static_cast<unsigned int>(Inputs::GetNumber(0, 10000, "Enter the y dimension of the new image -> ")),
        CV_8UC3
    );
}