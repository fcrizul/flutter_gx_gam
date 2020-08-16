import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_gx_gam/flutter_gx_gam.dart';
import 'package:flutter_gx_gam/models/gam_login_response.dart';
import 'package:flutter_gx_gam/models/sdt_service_response.dart';
import 'package:flutter_gx_gam/utils/validators_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para utilizar el GAM
class GAMService {
  static Future<GAMLoginResponse> login(String username, String password) async {
    // https://wiki.genexus.com/commwiki/servlet/wiki?15918,HowTo%3A+Develop+Secure+REST+Web+Services+in+GeneXus
    var body = {
      "client_id" : GAMConfig.clientId,
      "grant_type" : "password",
      "scope" : "FullControl",
      "username" : username,
      "password" : password
    };
  
    try {
      String url = "${GAMConfig.baseUrl}/oauth/access_token";
      
      _debug('Request url: $url');
      _debug('Request body: $body');
      
      var response = await http
          .post(url, body: body)
          .timeout(Duration(seconds: GAMConfig.timeout));
      
      _debug('Response status: ${response.statusCode}');
      _debug('Response body: ${response.body}');

      GAMHttpClient().store.clean();

      String responseBody = utf8.decode(response.bodyBytes);
      if (ValidatorsHelper.isJson(responseBody)) {
        var responseMap = json.decode(responseBody);
        if (response.statusCode == 200 && responseMap["access_token"] != null) {
          _debug('access_token: ' + responseMap["access_token"]);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', responseMap["access_token"]);

          _debug('Valor de access_token en sesion: ' + prefs.getString('access_token'));

          return GAMLoginResponse(loginOk: true);
        } else {
          if (responseMap.containsKey('error')) {
            final error = responseMap['error'];
            return GAMLoginResponse(errorCode: int.parse(error["code"]), errorMessage: error["message"]);
          }else{
            return GAMLoginResponse(errorCode: 700, errorMessage: responseMap['object'].toString());
          }
        }
      } else {
        return GAMLoginResponse(errorCode: response.statusCode, errorMessage: responseBody);
      }
    } on TimeoutException catch (_) {
      return GAMLoginResponse(errorCode: 1, errorMessage: "Error TimeoutException");
    } on SocketException catch (_) {
      return GAMLoginResponse(errorCode: 2, errorMessage: "Error SocketException");
    } on Exception catch (_) {
      return GAMLoginResponse(errorCode: 3, errorMessage: "Error Exception");
    }
  }

  static Future<GAMUser> getUser() async {
    var response = await _postUserInfo(true);
    try {
      if (response.statusCode == 200) {
        if (response.body != null && response.body.isNotEmpty){
          String responseBody = utf8.decode(response.bodyBytes);
          return GAMUser.fromJson(responseBody);
        }
      }
    } catch (_) {
      
    }
    return null;
  }

  static Future<bool> logout() async {
    try {
      String url = GAMConfig.baseUrl + "/oauth/logout";
      _debug('Request logout url: $url');
      
      Map<String, String> headers = new Map();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('access_token');
      if (token != null) headers['Authorization'] = 'OAuth ' + token;
      headers["Content-Type"] = "application/json;charset=utf-8";

      var response = await http
          .post(url, headers: headers)
          .timeout(Duration(seconds: GAMConfig.timeout));
      
      _debug('Response logout status: ${response.statusCode}');
      _debug('Response logout body: ${response.body}');
      
      if (response.statusCode == 200) {
        return true;
      } else {
        return true;
      }
    } on TimeoutException catch (_) {
      _error("Error al procesar la respuesta Response TimeoutException");
      return false;
    } on SocketException catch (_) {
      _error("Error al procesar la respuesta Response SocketException");
      return false;
    }
  }

  static Future<bool> isAuthenticated() async {
    GAMUser user = await getUser();
    if (user != null){
      return GAMConfig.checkAuthentication(user);
    }
    return false;
  }

  static Future<bool> isAuthorized(String permission) async {
    assert(GAMConfig.checkPermission != null, "GAMConfig().checkPermission is null");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('gam_token');
    if (token != null && token.isNotEmpty) {
      if (permission != null) {
        return GAMConfig.checkPermission(permission);
      }
    }

    return false;
  }

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("access_token");
    return token;
  }

  static Future<http.Response> _postUserInfo(bool useCache) async {
    assert(GAMConfig.baseUrl != null, "GAMConfig().baseUrl no puede ser vacío");

    try {
      return GAMHttp.post("/oauth/userinfo", useCache: useCache);
    } catch (_) {
     _debug(_);
      throw ("Error http");
    }
  }


  static void _debug(String texto){
    if ( GAMConfig.debug ) {
      print( 'gam_service: $texto' );
    }
  }

  static void _error(String texto){
    if ( GAMConfig.debug ) {
      print( 'gam_service: $texto' );
    }
  }
}
