import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gx_gam/flutter_gx_gam.dart';

/// Widget que se encargan de controlar permisos
class WidgetWithAuthorization extends StatefulWidget {
  final String permissionName;
  final String roleName;
  final Widget successful;
  final Widget wrong;

  WidgetWithAuthorization(
      {@required this.permissionName,
      this.roleName,
      @required this.successful,
      this.wrong});

  @override
  _WidgetWithAuthorization createState() => new _WidgetWithAuthorization();
}

class _WidgetWithAuthorization extends GAMState<WidgetWithAuthorization> {
  @override
  void initState() {
    super.initState();

    this.permissionName = widget.permissionName;
    this.roleName = widget.roleName;
    this.showProgress = false;
  }

  @override
  Widget buildAuthorized(BuildContext context) {
    return widget.successful;
  }

  @override
  Widget buildNotAuthorized(BuildContext context) {
    if (widget.wrong != null) {
      return widget.wrong;
    } else {
      return Container();
    }
  }
}
