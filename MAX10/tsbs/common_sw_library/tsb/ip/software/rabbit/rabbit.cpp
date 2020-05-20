/*
 * rabbit.cpp
 *
 *  Created on: May 27, 2014
 *      Author: yairlinn
 */




#include "rabbit.hpp"

namespace rabbit {

#define RABBIT_VAR_DEF(name, id) \
  const rapidjson::Type name::native_value = id; \
  const int name::value = id;

RABBIT_VAR_DEF(null_tag, rapidjson::kNullType)
RABBIT_VAR_DEF(false_tag, rapidjson::kFalseType)
RABBIT_VAR_DEF(true_tag, rapidjson::kTrueType)
RABBIT_VAR_DEF(object_tag, rapidjson::kObjectType)
RABBIT_VAR_DEF(array_tag, rapidjson::kArrayType)
RABBIT_VAR_DEF(string_tag, rapidjson::kStringType)
RABBIT_VAR_DEF(number_tag, rapidjson::kNumberType)
}
