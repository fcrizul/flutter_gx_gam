import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gx_gam/flutter_gx_gam.dart';

/// State para controlar permisos en pantalla
mixin GAMState<T extends StatefulWidget> on State<T> {
  String permission;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(( _ ) => _checkPermission( context ));
  }

  Future<void> _checkPermission( BuildContext context) async {
    bool isAuthenticated = await GAMService.isAuthenticated();

    if (permission != null && permission.isNotEmpty){
      bool isAuthorized = await GAMService.isAuthorized(permission);
      if (isAuthorized){
        authorized(context);
        return;
      }
    }else{
      if (isAuthenticated){
        authorized(context);
        return;
      }
    }

    notAuthorized(context, isAuthenticated);
  }

  void authorized( BuildContext context );
  void notAuthorized( BuildContext context, bool authenticated);
}
