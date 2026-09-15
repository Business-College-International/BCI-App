import 'package:dio/dio.dart';

class ApplicationStatusView {
  const ApplicationStatusView({
    required this.trackingCode,
    required this.levelApplied,
    required this.programmeApplied,
    required this.status,
  });

  final String trackingCode;
  final String levelApplied;
  final String programmeApplied;
  final String status;

  factory ApplicationStatusView.fromJson(Map<String, dynamic> json) {
    return ApplicationStatusView(
      trackingCode: json['trackingCode'] as String,
      levelApplied: json['levelApplied'] as String,
      programmeApplied: json['programmeApplied'] as String,
      status: json['status'] as String,
    );
  }
}

class ApplicationApi {
  ApplicationApi({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: const String.fromEnvironment(
                  'BCI_API_BASE_URL',
                  defaultValue: 'http://10.0.2.2:3000/api/v1',
                ),
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  final Dio _dio;

  Future<ApplicationStatusView> getStatus(String trackingCode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/applications/track/$trackingCode',
    );
    return ApplicationStatusView.fromJson(response.data!);
  }
}
