/// Estructura de respuesta genérica de GAM
class ServiceResponse {
  ServiceErrorResponse error;
  Object object;
  int statusCode;

  ServiceResponse({this.error, this.object, this.statusCode});
  ServiceResponse.fromJson(Map map) {
    if (map.containsKey('error') || map.containsKey('object')) {
      this.error = map.containsKey('error')
          ? ServiceErrorResponse.fromJson(map['error'])
          : null;
      this.object = map.containsKey('object') ? map['object'] : null;
    } else {
      throw ("El JSON no corresponde al objeto ServiceResponse");
    }
  }

  log() {
    print("-----------------------------------------------------------");
    print("ServiceResponse: statusCode" + this.statusCode.toString());
    print("ServiceResponse: object" + this.object.toString());
    print("ServiceResponse: error" + this.error.toJson().toString());
    print("-----------------------------------------------------------");
  }

  Map toJson() {
    var map = new Map<String, dynamic>();
    map["statusCode"] = this.statusCode;
    map["error"] = this.error.toJson();
    map["object"] = this.object.toString();
    return map;
  }
}

/// Estrucutra de respuesta de errores de GAM
class ServiceErrorResponse {
  String code;
  String message;

  ServiceErrorResponse({this.code, this.message});

  ServiceErrorResponse.fromJson(Map map) {
    this.code = map["code"];
    this.message = map["message"];
  }

  log() {
    print("-----------------------------------------------------------");
    print("ServiceErrorResponse: code " + this.code.toString());
    print("ServiceErrorResponse: message" + this.message.toString());
    print("-----------------------------------------------------------");
  }

  Map toJson() {
    var map = new Map<String, dynamic>();
    map["code"] = this.code;
    map["message"] = this.message;
    return map;
  }
}
