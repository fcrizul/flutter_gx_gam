import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_gx_gam/flutter_gx_gam.dart';
import 'package:flutter_gx_gam/utils/validators_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  static Future<ServiceResponse> post(String url,
      {Map<String, String> headers,
      body,
      Encoding encoding,
      bool useCache = false,
      bool useThrow = true}) async {
    try {
      if (headers == null) {
        headers = new Map();
      }
      if (!url.startsWith(new RegExp('^(http|https)://'))) {
        if (!url.startsWith(new RegExp('/'))) {
          url = '/' + url;
        }
        url = GAMConfig().baseUrl + url;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("access_token");
      if (token != null) headers['Authorization'] = 'OAuth ' + token;
      headers["Content-Type"] = "application/json;charset=utf-8";

      if (GAMConfig().debug) {
        print('GAMHttp: Request url: $url');
        print('GAMHttp: Request body: $body');
        print('GAMHttp: Request header: $headers');
      }

      http.Response response;
      if (useCache) {
        response = await GAMHttpClient().httpClientCache.postWithOptions(url,
            headers: headers, body: body, encoding: encoding);

        //.timeout(const Duration(seconds: wsRestTimeout));
      } else {
        response = await GAMHttpClient()
            .httpClient
            .post(
              url,
              headers: headers,
              body: body,
              encoding: encoding,
            )
            .timeout(Duration(seconds: (GAMConfig().timeout)));
      }
      int statusCode = response.statusCode;
      if (GAMConfig().debug) {
        print('GAMHttp: Response code: ${response.statusCode}');
        print('GAMHttp: Response body: ${response.body}');
      }
      ServiceResponse serviceResponse = ServiceResponse();
      String responseBody = utf8.decode(response.bodyBytes);

      if (ValidatorsHelper.isJson(responseBody)) {
        Map responseMap = json.decode(responseBody);
        try {
          serviceResponse = ServiceResponse.fromJson(responseMap);
        } catch (_) {
          if (GAMConfig().debug) print(_);
          serviceResponse = ServiceResponse();
          serviceResponse.object = responseMap;
          serviceResponse.error =
              ServiceErrorResponse(code: statusCode.toString(), message: "");
        }
      } else {
        serviceResponse.object = responseBody;
        serviceResponse.error = ServiceErrorResponse(
            code: statusCode.toString(),
            message: (statusCode == 200) ? "" : responseBody);
      }
      serviceResponse.statusCode = statusCode;
      if (statusCode != 200 && useThrow) {
        if (serviceResponse.error != null) {
          throw (serviceResponse.error.message);
        } else {
          throw ("Error http ${serviceResponse.error}");
        }
      }

      return Future(() {
        return serviceResponse;
      });
    } on TimeoutException catch (_) {
      print("Error al procesar la respuesta Response TimeoutException");
      throw ("-");
    } on SocketException catch (_) {
      print("Error al procesar la respuesta Response SocketException");
      throw ("-");
    }
  }
}
