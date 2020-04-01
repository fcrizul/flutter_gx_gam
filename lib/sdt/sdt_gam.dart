

import 'package:gx_gam/gx_gam.dart';

class SDTGAMUser {
  final String name;
  final String firstName;
  final String lastName;
  final String eMail;
  final String birthday;
  final String gender;
  final String urlImage;
  final String urlProfile;

  SDTGAMUser(this.name, this.firstName, this.lastName, this.eMail, this.birthday, this.gender, this.urlImage, this.urlProfile);

  @override
  Map toJson() {
    var map = new Map<String, dynamic>();
    map["Name"] = this.name;
    map["FirstName"] = this.firstName;
    map["LastName"] = this.lastName;
    map["EMail"] = this.eMail;
    map["Birthday"] = this.birthday;
    map["Gender"] = this.gender;
    map["URLImage"] = this.urlImage;
    map["URLProfile"] = this.urlProfile;
    return map;
  }

  void log(){
    print("-----------------------------------------------------------");
    print("SDTGAMUser: name: " + this.name);
    print("SDTGAMUser: firstName: " + this.firstName);
    print("SDTGAMUser: lastName: " + this.lastName);
    print("SDTGAMUser: eMail: " + this.eMail);
    print("SDTGAMUser: birthday: " + this.birthday);
    print("SDTGAMUser: gender: " + this.gender);
    print("SDTGAMUser: urlImage: " + this.urlImage);
    print("SDTGAMUser: urlProfile: " + this.urlProfile);
    print("-----------------------------------------------------------");
  }

  @override
  factory SDTGAMUser.fromJson(Map json) {
    try{
      return SDTGAMUser(
        json["Name"],
        json["FirstName"],
        json["LastName"],
        json["EMail"],
        json["Birthday"],
        json["Gender"],
        json["URLImage"],
        json["URLProfile"],
      );
    } catch (_){
      if (GAMConfig().debug)
        print("El json no es un elemento de SDTGAMUser");
      throw("El json no es un elemento de SDTGAMUser");
    }
  }
}