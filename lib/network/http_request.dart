import 'package:dio/dio.dart';

class HttpRequest {
  static final BaseOptions baseOptions = BaseOptions(
    baseUrl: "https://api.wmdb.tv/api/v1"
  );
  static final Dio dio = Dio(baseOptions);

  static Future<T?> request<T>(String url,
      {String method = "get", Map<String, dynamic>? params}) async {
    // 1.创建单独配置
    final options = Options(method: method);
    // 2.发送网络请求
    try {
      final result =
          await dio.request<T>(url, queryParameters: params, options: options);
      return result.data;
    } on DioError catch (e) {
      throw e;
    }
  }
}