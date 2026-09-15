import 'package:dio/dio.dart';

class ApplicationSummary {
  const ApplicationSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.levelApplied,
    required this.programmeApplied,
    required this.status,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String levelApplied;
  final String programmeApplied;
  final String status;

  factory ApplicationSummary.fromJson(Map<String, dynamic> json) {
    return ApplicationSummary(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
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

  Future<ApplicationSummary> getStatus(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/applications/$id/status',
    );
    return ApplicationSummary.fromJson(response.data!);
  }
}
