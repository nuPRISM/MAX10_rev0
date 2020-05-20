/*
 * cpp_utils.cpp
 *
 *  Created on: Sep 20, 2013
 *      Author: yairlinn
 */

#include <string>
#include <algorithm>
#include <functional>
#include "cpp_utils.h"

std::string remove_nonalphanumeric(std::string input) {
    input.erase(
        std::remove_if(input.begin(), input.end(), std::not1(std::ptr_fun(( int (*)( int))std::isalnum))),
        input.end());
    return input;
}


std::string remove_spaces(std::string input) {
    input.erase(
        std::remove_if(input.begin(), input.end(), std::ptr_fun(( int (*)( int))std::isspace)),
        input.end());
    return input;
}
std::string only_graphable(std::string input) {
    input.erase(
        std::remove_if(input.begin(), input.end(), std::not1(std::ptr_fun(( int (*)( int))std::isgraph))),
        input.end());
    return input;
}
