import 'package:flutter/foundation.dart';
import 'package:flutter_gx_gam/flutter_gx_gam.dart';

/// Clase de configuración de GAM
class GAMConfig {
  static final _GAMConfigProperties _properties = _GAMConfigProperties();

  static void setProperties(
      {bool debug,
      int timeout,
      @required String baseUrl,
      @required String clientId,
      @required String clientSecret,
      @required Future<bool> Function(GAMUser user) checkAuthentication,
      @required Future<bool> Function(String permission) checkPermission}) {
    if (debug != null) _properties.debug = debug;
    if (baseUrl != null) _properties.baseUrl = baseUrl;
    if (clientId != null) _properties.clientId = clientId;
    if (timeout != null) _properties.timeout = timeout;
    if (clientSecret != null) _properties.clientSecret = clientSecret;
    if (checkAuthentication != null)
      _properties.checkAuthentication = checkAuthentication;
    if (checkPermission != null) _properties.checkPermission = checkPermission;
  }

  static String get baseUrl {
    assert(_properties.baseUrl != null,
        "El baseUrl no puede ser vacío, llame a GAMConfig.setProperties");

    return _properties.baseUrl.trim();
  }

  static String get clientId {
    assert(_properties.clientId != null,
        "El clientId no puede ser vacío, llame a GAMConfig.setProperties");

    return _properties.clientId.trim();
  }

  static bool get debug {
    return _properties.debug;
  }

  static int get timeout {
    return _properties.timeout;
  }

  static Future<bool> checkPermission(String permission) {
    return _properties.checkPermission(permission);
  }

  static Future<bool> checkAuthentication(GAMUser user) {
    return _properties.checkAuthentication(user);
  }
}

class _GAMConfigProperties {
  bool debug = false;
  int version = 1;
  int timeout = 15;
  String authenticationTypeName = "";
  String baseUrl;
  String clientId;
  String clientSecret;
  Future<bool> Function(String permission) checkPermission;
  Future<bool> Function(GAMUser user) checkAuthentication;
}
