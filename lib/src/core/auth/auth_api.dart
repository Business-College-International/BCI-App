import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/guardian/academic_report_models.dart';
import '../../features/guardian/invoice_models.dart';
import 'auth_models.dart';

class AuthApi {
  AuthApi({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: const String.fromEnvironment(
                  'BCI_API_BASE_URL',
                  defaultValue: 'http://10.0.2.2:3000/api/v1',
                ),
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                headers: {'Content-Type': 'application/json'},
              ),
            ),
        _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const _accessKey = 'bci_access_token';
  static const _refreshKey = 'bci_refresh_token';

  Future<CurrentUser> login({required String identifier, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'identifier': identifier.trim(), 'password': password},
    );
    await _saveTokens(AuthTokens.fromJson(response.data!));
    return currentUser();
  }

  Future<CurrentUser> currentUser() async {
    final response = await _authorizedGet('/auth/me');
    return CurrentUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<WardView>> wards() async {
    final response = await _authorizedGet('/students/me/wards');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => WardView.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<AcademicReportView> currentAcademicReport(String studentId) async {
    final response = await _authorizedGet('/academic-reports/students/$studentId/current');
    return AcademicReportView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<InvoiceView>> studentInvoices(String studentId) async {
    final response = await _authorizedGet('/finance/students/$studentId/invoices');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => InvoiceView.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> logout() async {
    final refreshToken = await _storage.read(key: _refreshKey);
    try {
      if (refreshToken != null) {
        await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      }
    } finally {
      await _clearTokens();
    }
  }

  Future<Response<dynamic>> _authorizedGet(String path) async {
    try {
      return await _dio.get<dynamic>(
        path,
        options: Options(headers: {'Authorization': 'Bearer ${await _accessToken()}'}),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) rethrow;

      await _refresh();
      return _dio.get<dynamic>(
        path,
        options: Options(headers: {'Authorization': 'Bearer ${await _accessToken()}'}),
      );
    }
  }

  Future<String> _accessToken() async {
    final token = await _storage.read(key: _accessKey);
    if (token == null || token.isEmpty) throw StateError('No BCI access token is available.');
    return token;
  }

  Future<void> _refresh() async {
    final refreshToken = await _storage.read(key: _refreshKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearTokens();
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        error: 'No refresh token is available.',
      );
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    await _saveTokens(AuthTokens.fromJson(response.data!));
  }

  Future<void> _saveTokens(AuthTokens tokens) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: tokens.accessToken),
      _storage.write(key: _refreshKey, value: tokens.refreshToken),
    ]);
  }

  Future<void> _clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
  }
}
