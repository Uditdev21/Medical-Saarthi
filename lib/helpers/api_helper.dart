import 'dart:ffi';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:healthapp/view_models/services/auth_services.dart';

class ApiHelper {
  static final String baseUrl = "http://10.0.2.2:8000";
  static dio.Dio? _dio;

  final String token = Get.find<AuthServices>().token.value;

  /// 🔹 Initialize Dio once
  static void init() {
    if (_dio != null) return;
    dio.BaseOptions options = dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: dio.ResponseType.json,
    );

    _dio = dio.Dio(options);
    _dio!.options.validateStatus = (status) {
      return status != null && status >= 200 && status <= 500;
    };
    _dio!.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          print("➡️ [REQUEST] ${options.method} ${options.uri}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("✅ [RESPONSE] ${response.statusCode} => ${response.data}");
          return handler.next(response);
        },
        onError: (dio.DioException e, handler) {
          print("❌ [ERROR] ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }

  /// 🔹 Set Authorization Bearer Token
  static void setToken(String token) {
    init();
    _dio!.options.headers['Authorization'] = 'Bearer $token';
    // prin
  }

  /// 🔹 Normal JSON requests
  static Future<dio.Response> getData(String endpoint) async {
    init();
    return await _dio!.get(endpoint);
  }

  static Future<dio.Response> postData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    init();
    return await _dio!.post(endpoint, data: data);
  }

  static Future<dio.Response> putData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    init();
    return await _dio!.put(endpoint, data: data);
  }

  static Future<dio.Response> deleteData(String endpoint) async {
    init();
    return await _dio!.delete(endpoint);
  }

  static Future<dio.Response> patchData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    init();
    return await _dio!.patch(endpoint, data: data);
  }

  /// 🔹 Form data request (application/x-www-form-urlencoded)
  static Future<dio.Response> postForm(
    String endpoint,
    Map<String, dynamic> formData,
  ) async {
    init();
    return await _dio!.post(
      endpoint,
      data: dio.FormData.fromMap(formData),
      options: dio.Options(contentType: dio.Headers.formUrlEncodedContentType),
    );
  }

  /// 🔹 Multipart request (file upload)
  static Future<dio.Response> uploadFile(
    String endpoint, {
    required File file,
    Map<String, dynamic>? fields,
    String fieldName = "file",
    Function(int, int)? onSendProgress,
  }) async {
    init();
    final formData = dio.FormData.fromMap({
      ...?fields,
      fieldName: await dio.MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });

    return await _dio!.post(
      endpoint,
      data: formData,
      options: dio.Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );
  }
}
