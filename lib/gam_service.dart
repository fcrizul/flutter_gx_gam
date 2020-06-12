import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gx_gam/flutter_gx_gam.dart';
import 'package:flutter_gx_gam/utils/validators_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para utilizar el GAM
class GAMService {
  static Future<ServiceResponse> login(String username, String password) async {
    String body = "client_id=" +
        GAMConfig().clientId +
        "&grant_type=password&scope=FullControl&username=" +
        username +
        "&password=" +
        password;
    try {
      String url = GAMConfig().baseUrl + "/oauth/access_token";
      if (GAMConfig().debug) {
        print('Request url: $url');
        print('Request body: $body');
      }

      var response = await http
          .post(url, body: body)
          .timeout(Duration(seconds: GAMConfig().timeout));
      if (GAMConfig().debug) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      GAMHttpClient().store.clean();
      String responseBody = utf8.decode(response.bodyBytes);
      if (ValidatorsHelper.isJson(responseBody)) {
        var responseMap = json.decode(responseBody);
        if (response.statusCode == 200) {
          if (GAMConfig().debug)
            print('access_token: ' + responseMap["access_token"]);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', responseMap["access_token"]);

          if (GAMConfig().debug)
            print('Valor de access_token en sesion: ' +
                prefs.getString('access_token'));

          return ServiceResponse.fromJson({
            "error": {"code": "1", "message": "Login correcto!"}
          });
        } else {
          return ServiceResponse.fromJson(responseMap);
        }
      } else {
        return ServiceResponse.fromJson({
          "error": {
            "code": "${response.statusCode}",
            "message": "$responseBody"
          }
        });
      }
    } on TimeoutException catch (_) {
      return ServiceResponse.fromJson({
        "error": {
          "code": "500",
          "message": "Error al procesar la respuesta Response TimeoutException"
        }
      });
    } on SocketException catch (_) {
      return ServiceResponse.fromJson({
        "error": {
          "code": "500",
          "message": "Error al procesar la respuesta Response SocketException"
        }
      });
    } on Exception catch (_) {
      return ServiceResponse.fromJson({
        "error": {"code": "500", "message": "Error al realizar el request: $_"}
      });
    }
  }

  static Future<bool> logout(BuildContext context) async {
    try {
      String url = GAMConfig().baseUrl + "/oauth/logout";
      if (GAMConfig().debug) {
        print('Request logout url: $url');
      }
      Map<String, String> headers = new Map();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('access_token');
      if (token != null) headers['Authorization'] = 'OAuth ' + token;
      headers["Content-Type"] = "application/json;charset=utf-8";

      var response = await http
          .post(url, headers: headers)
          .timeout(Duration(seconds: GAMConfig().timeout));
      if (GAMConfig().debug) {
        print('Response logout status: ${response.statusCode}');
        print('Response logout body: ${response.body}');
      }

      if (response.statusCode == 200) {
        prefs.remove("access_token");
        Navigator.pushReplacementNamed(context, GAMConfig().loginRoute);
        return true;
      } else {
        return true;
      }
    } on TimeoutException catch (_) {
      print("Error al procesar la respuesta Response TimeoutException");
      return false;
    } on SocketException catch (_) {
      print("Error al procesar la respuesta Response SocketException");
      return false;
    }
  }

  static Future<SDTGAMUser> userInfo() async {
    var response = await _postUserInfo(true);
    try {
      if (response.statusCode == 200) {
        return SDTGAMUser.fromJson(response.object);
      } else {
        return SDTGAMUser("", "", "", "", "", "", "", "");
      }
    } catch (_) {
      return SDTGAMUser("", "", "", "", "", "", "", "");
    }
  }

  static Future<ServiceResponse> _postUserInfo(bool useCache) async {
    try {
      String url = GAMConfig().baseUrl + "/oauth/userinfo";
      if (GAMConfig().debug) {
        print('Request _postUserInfo url: $url');
      }
      ServiceResponse response = await GAMHttp.post(url, useCache: useCache);
      if (GAMConfig().debug) {
        print('Response _postUserInfo status: ${response.statusCode}');
        print('Response _postUserInfo object: ${response.object}');
      }
      return response;
    } catch (_) {
      throw (_);
    }
  }

  static Future<bool> isAuthenticated(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString('access_token');
    if (value != null && value.isNotEmpty) {
      try {
        _postUserInfo(false);
        return true;
      } catch (_) {
        prefs.remove("access_token");
        Navigator.pushReplacementNamed(context, GAMConfig().loginRoute);
        return false;
      }
    }
    return false;
  }

  static Future<ServiceErrorResponse> isAuthorized(
      {String permissionName, String roleName}) async {
    var serviceErrorResponse;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      if (permissionName == null && roleName == null) {
        try {
          String url = GAMConfig().baseUrl + "/rest/gam_io/CheckAuthentication";
          if (GAMConfig().debug) {
            print('Request _checkPermission url: $url');
          }
          ServiceResponse response = await GAMHttp.post(url,
              body: '', useCache: false, useThrow: false);
          if (GAMConfig().debug) {
            print('Response _checkRole statusCode: ${response.statusCode}');
            print('Response _checkRole code: ${response.error.code}');
          }
          return Future(() {
            return response.error;
          });
        } catch (_) {
          print(_);
          prefs.remove('access_token');
          serviceErrorResponse = ServiceErrorResponse.fromJson(
              {"code": "401", "message": "Unauthorized"});
        }
      } else {
        if (permissionName != null) {
          serviceErrorResponse = _checkPermission(permissionName);
        } else {
          serviceErrorResponse = _checkRole(roleName);
        }
      }
    } else {
      serviceErrorResponse = ServiceErrorResponse.fromJson(
          {"code": "401", "message": "Unauthorized"});
    }
    return Future(() {
      return serviceErrorResponse;
    });
  }

  static Future<ServiceErrorResponse> _checkPermission(
      String permission) async {
    String url = GAMConfig().baseUrl + "/rest/gam_io/CheckPermission";
    if (GAMConfig().debug) {
      print('Request _checkPermission url: $url');
    }
    ServiceResponse response = await GAMHttp.post(url,
        body: '{"PermissionName":"$permission"}',
        useCache: false,
        useThrow: false);
    if (GAMConfig().debug) {
      print('Response _checkRole statusCode: ${response.statusCode}');
      print('Response _checkRole code: ${response.error.code}');
    }
    return Future(() {
      return response.error;
    });
  }

  static Future<ServiceErrorResponse> _checkRole(String role) async {
    String url = GAMConfig().baseUrl + "/rest/gam_io/CheckRole";
    if (GAMConfig().debug) {
      print('Request _checkRole url: $url');
    }
    ServiceResponse response = await GAMHttp.post(url,
        body: '{"roleName":"$role"}', useCache: false, useThrow: false);
    if (GAMConfig().debug) {
      print('Response _checkRole statusCode: ${response.statusCode}');
      print('Response _checkRole code: ${response.error.code}');
    }
    return Future(() {
      return response.error;
    });
  }
}
