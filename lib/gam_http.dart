import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_gx_gam/flutter_gx_gam.dart';
import 'package:http/http.dart' as http;
import 'package:http_extensions/http_extensions.dart';
import 'package:http_extensions_cache/http_extensions_cache.dart';

/// HTTPClient para GAM, reutiliza la conexión e implementa cache para algunas llamas
class GAMHttpClient {
  static final GAMHttpClient _singleton = GAMHttpClient._internal();
  MemoryCacheStore store;
  ExtendedClient httpClientCache;
  http.Client httpClient;

  void init() {
    store = MemoryCacheStore();
    httpClientCache = ExtendedClient(
      inner: http.Client(),
      extensions: [
        CacheExtension(
            defaultOptions:
                CacheOptions(store: store, expiry: const Duration(minutes: 5))),
      ],
    );
    httpClient = http.Client();
  }

  factory GAMHttpClient() {
    return _singleton;
  }

  GAMHttpClient._internal() {
    init();
  }
}

/// Conexión mediante REST con la API del GAM
class GAMHttp {
  static Future<http.Response> post(String url,
      {Map<String, String> headers,
      body,
      Encoding encoding,
      bool useCache = false,
      bool useThrow = true}) async {
    String token = await GAMService.getToken();
    if (token == null) {
      return http.Response("Unauthorized", 401);
    }

    try {
      if (headers == null) {
        headers = new Map();
      }
      if (!url.startsWith(new RegExp('^(http|https)://'))) {
        if (!url.startsWith(new RegExp('/'))) {
          url = '/' + url;
        }
        url = GAMConfig.baseUrl + url.trim();
      }

      headers["Authorization"] = 'OAuth $token';
      headers["Content-Type"] = "application/json;charset=utf-8";

      if (GAMConfig.debug) {
        print('GAMHttp: Request url: $url');
        print('GAMHttp: Request body: $body');
        print('GAMHttp: Request header: $headers');
      }

      if (useCache) {
        return GAMHttpClient().httpClientCache.postWithOptions(url,
            headers: headers, body: body, encoding: encoding);

        //.timeout(const Duration(seconds: wsRestTimeout));
      } else {
        return GAMHttpClient()
            .httpClient
            .post(
              url,
              headers: headers,
              body: body,
              encoding: encoding,
            )
            .timeout(Duration(seconds: (GAMConfig.timeout)));
      }
    } on TimeoutException catch (_) {
      print("Error al procesar la respuesta Response TimeoutException");
      throw ("-");
    } on SocketException catch (_) {
      print("Error al procesar la respuesta Response SocketException");
      throw ("-");
    }
  }
}
