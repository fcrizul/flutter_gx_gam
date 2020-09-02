import 'dart:convert';

import 'package:flutter_gx_gam/gam_config.dart';

/// Datos basicos del usuario almacenados en GAM
class GAMUser {
  final String guid;
  final String nameSpace;
  final String authenticationTypeName;
  final String externalId;
  final String name;
  final String firstName;
  final String lastName;
  final String eMail;
  final String birthday;
  final String gender;
  final String urlImage;
  final String urlProfile;

  GAMUser(
      this.guid,
      this.nameSpace,
      this.authenticationTypeName,
      this.externalId,
      this.name,
      this.firstName,
      this.lastName,
      this.eMail,
      this.birthday,
      this.gender,
      this.urlImage,
      this.urlProfile);

  Map toJson() {
    var map = new Map<String, dynamic>();
    map["Name"] = this.name;
    map["NameSpace"] = this.nameSpace;
    map["AuthenticationTypeName"] = this.authenticationTypeName;
    map["ExternalId"] = this.externalId;
    map["FirstName"] = this.firstName;
    map["LastName"] = this.lastName;
    map["EMail"] = this.eMail;
    map["Birthday"] = this.birthday;
    map["Gender"] = this.gender;
    map["URLImage"] = this.urlImage;
    map["URLProfile"] = this.urlProfile;
    map["GUID"] = this.guid;
    return map;
  }

  void log() {
    print("-----------------------------------------------------------");
    print("GAMUser: name: " + this.name);
    print("GAMUser: firstName: " + this.firstName);
    print("GAMUser: lastName: " + this.lastName);
    print("GAMUser: eMail: " + this.eMail);
    print("GAMUser: birthday: " + this.birthday);
    print("GAMUser: gender: " + this.gender);
    print("GAMUser: urlImage: " + this.urlImage);
    print("GAMUser: urlProfile: " + this.urlProfile);
    print("-----------------------------------------------------------");
  }

  @override
  factory GAMUser.fromJson(String jsonStr) {
    try {
      final map = json.decode(jsonStr);
      return GAMUser(
        map["GUID"],
        map["NameSpace"],
        map["AuthenticationTypeName"],
        map["ExternalId"],
        map["Name"],
        map["FirstName"],
        map["LastName"],
        map["EMail"],
        map["Birthday"],
        map["Gender"],
        map["URLImage"],
        map["URLProfile"],
      );
    } catch (_) {
      if (GAMConfig.debug) print("El json no es un elemento de SDTGAMUser");
      throw ("El json no es un elemento de SDTGAMUser");
    }
  }
}
