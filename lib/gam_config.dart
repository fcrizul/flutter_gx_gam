/// Clase de configuración de GAM
class GAMConfig {
  static final GAMConfig _singleton = GAMConfig._internal();

  bool debug;
  int version = 1;
  String baseUrl = "";
  String clientId = "";
  int timeout = 15;
  String loginRoute = "\login";

  void init() {
    debug = false;
  }

  void setProperties(
      {bool debug, String baseUrl, String clientId, int timeout}) {
    if (debug != null) this.debug = debug;
    if (baseUrl != null) this.baseUrl = baseUrl;
    if (clientId != null) this.clientId = clientId;
    if (timeout != null) this.timeout = timeout;
  }

  factory GAMConfig() {
    return _singleton;
  }

  GAMConfig._internal() {
    init();
  }

  void log() {}
}
