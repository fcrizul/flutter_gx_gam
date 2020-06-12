library validators_helper;

import 'dart:convert';

/// Clase para validaciones 
abstract class ValidatorsHelper{
  static const String PATTERN_EMAIL         = "^([0-9a-zA-Z]([-.+\\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\\w]*[0-9a-zA-Z]\\.)+[a-zA-Z]{2,9})\$";
  static const String PATTERN_URL           = "^([0-9a-zA-Z]([-.+\\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\\w]*[0-9a-zA-Z]\\.)+[a-zA-Z]{2,9})\$";
  static const String PATTERN_ALPHANUMERIC  = "^[a-zA-Z0-9öäüÖÄÜß]+\$";
  static const String PATTERN_HEX           = "^(0x[a-fA-F0-9]+)|([a-fA-F0-9])+\$";
  static const String PATTERN_UUID          = "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}\$";
  static const String PATTERN_COORDINATES   = r"^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$";

  static bool isMatchPattern(String input, String pattern) {
      return new RegExp(pattern).hasMatch(input);
  }

  static bool isUrl(String input) {
    if (!Uri.parse(input).isAbsolute)
      return false;
    return true;
  }

  static bool isEmail(String input) {
    if (!isMatchPattern(input,PATTERN_EMAIL))
      return false;
    return true;
  }

  static bool isCoordinates(String input) {
    if (!isMatchPattern(input,PATTERN_COORDINATES))
      return false;
    return true;
  }

  static bool isJson(String jsonString){
    try {
      var decode = json.decode(jsonString) as Map<String, dynamic>;
      return (decode != null);
    } on FormatException catch (_) {
      //print('The provided string is not valid JSON');
    }
    return false;
  }
}