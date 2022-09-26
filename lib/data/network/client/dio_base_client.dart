import 'package:dio/dio.dart';
import 'package:stripe_gateway_implementation/data/network/api/constants/end_points.dart';
import 'package:stripe_gateway_implementation/utils/constants.dart';

import 'api_interceptor.dart';

class DioBaseClient {
  static final DioBaseClient _dioClient = DioBaseClient._internal();
  late Dio _dio;

  factory DioBaseClient() {
    return _dioClient;
  }

  Dio get client => _dio;

  DioBaseClient._internal() {
    var options = BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );

    _dio = Dio(options);
    _dio.interceptors.addAll(getInterceptors());
  }

  Future<Response> postPayment(
    String url, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      _dio.options.headers["Authorization"] =
          "Bearer ${Constants.stripeSecretKey}";
      final Response response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
