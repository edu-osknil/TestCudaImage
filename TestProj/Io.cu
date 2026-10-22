#include <stdio.h>
#include <iostream>
#include <algorithm>
#include <list>
#include <unordered_map>
#include <string>
#include <opencv2/opencv.hpp>
#include <cctype>
#include "Color.cu"

extern "C" void TintImage(cv::Mat& image);

enum class Actions{
    tint,
    show,
    overlay,
    help,
    quit
};

static const std::unordered_map<std::string, Actions> actionMap = {
    {"help", Actions::help},
    {"tint", Actions::tint},
    {"overlay", Actions::overlay},
    {"show", Actions::show},
    {"quit", Actions::quit}
};
class Outputs{
public:
    static void PrintOptions(){
        std::cout << "\n";
        for (auto& kvp : actionMap){
            if (kvp.second == Actions::help)
                continue;
            std::cout << kvp.first << "\n";
        }
        std::cout << "\n";
    }
};
class Inputs{
private:
    static bool IsValidHexColor(std::string hexadecimal){
        if (hexadecimal.size() != 6){
            std::cout << "Invalid length\n";
            return false;
        }
        for (unsigned char c : hexadecimal){
            if (!std::isxdigit(c)){
                std::cout << "Invalid hex code\n";
                return false;
        }
        }
        return true;
    }
    static std::string GetFilePath(){
        std::cout << "Enter image path -> ";
        std::string filePath;
        getline(std::cin, filePath);
        replace(filePath.begin(), filePath.end(), '\\', '/');
        filePath.erase(remove(filePath.begin(), filePath.end(), '"'), filePath.end()); 
        return filePath;
    }
public:
    static cv::Mat ImportImage(){
        cv::Mat image;
        while (true){
            image = cv::imread(
                GetFilePath(),
                cv::IMREAD_COLOR
            );
            if (image.empty())
                std::cout << "No image found" << std::endl;
            else
                break;
        }
        return image;
    }
    static Color GetColor(){ 
        while (true){
            std::string hexadecimal;
            std::cout << "Enter a color in hexadecimal -> ";
            std::cin >> hexadecimal;
            hexadecimal.erase(remove(hexadecimal.begin(), hexadecimal.end(), '#'), hexadecimal.end());
            if (!IsValidHexColor(hexadecimal))
                continue;
            int value = std::stoul(hexadecimal, nullptr, 16);
            return Color(
                value & 0xFF,
                (value >> 8) & 0xFF,
                (value >> 16) & 0xFF
            );
        }
    }
    static float GetNumber(float minRange, float maxRange, std::string descText){
        std::cout << descText;
        std::cout << "Enter a number between " << minRange << " and " << maxRange << "\n"; 
        float value;
        std::cin >> value;
        return std::clamp(value, minRange, maxRange);
    }
    static bool UpdateImage(cv::Mat& image){
        while (true){
            std::string selectedActionStr;
            std::cin >> selectedActionStr;
            auto item = actionMap.find(selectedActionStr);
            if (item != actionMap.end()){
                Actions action = item->second;
                switch (action){
                    case Actions::help:
                        Outputs::PrintOptions();
                        return true;
                    case Actions::show:
                        cv::imshow("Image", image);
                        cv::waitKey(0);
                        return true;
                    case Actions::tint:
                        TintImage(image);
                        return true;
                    case Actions::quit:
                        return false;
                }
            }
            std::cout << "Invalid input\n";
        }
    }
};