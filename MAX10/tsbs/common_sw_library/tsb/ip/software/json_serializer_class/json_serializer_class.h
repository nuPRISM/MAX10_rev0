/*
 * json_serializer_class.h
 *
 *  Created on: May 28, 2014
 *      Author: yairlinn
 */

#ifndef JSON_SERIALIZER_CLASS_H_
#define JSON_SERIALIZER_CLASS_H_

#include "jansson.hpp"
#include <string>

class json_serializer_class {
public:
public:
   virtual ~json_serializer_class( void ) {};
   virtual json::Value get_json_object() =0;
   virtual std::string get_json_string();
};

#endif /* JSON_SERIALIZER_CLASS_H_ */
