class GAMLoginResponse {
  bool loginOk;
  int errorCode;
  String errorMessage;

  GAMLoginResponse(
      {bool loginOk = false, int errorCode = 0, String errorMessage = ""}) {
    this.loginOk = loginOk;
    this.errorCode = errorCode;
    this.errorMessage = errorMessage;
  }
}
