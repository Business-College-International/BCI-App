import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/guardian/academic_report_models.dart';
import '../../features/guardian/announcement_models.dart';
import '../../features/guardian/attendance_models.dart';
import '../../features/guardian/guardian_profile_models.dart';
import '../../features/guardian/invoice_models.dart';
import '../../features/guardian/payment_preflight_models.dart';
import '../../features/guardian/receipt_models.dart';
import '../../features/guardian/wallet_models.dart';
import '../../features/notifications/notification_models.dart';
import '../../features/security/security_models.dart';
import '../../features/staff/staff_models.dart';
import '../../features/staff/teacher_attendance_models.dart';
import '../../features/staff/teacher_assessment_models.dart';
import '../../features/stationery_store/stationery_models.dart';
import 'auth_models.dart';

class AuthApi {
  AuthApi({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: const String.fromEnvironment('BCI_API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/api/v1'),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        )),
        _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;
  static const _accessKey = 'bci_access_token';
  static const _refreshKey = 'bci_refresh_token';
  Future<void>? _refreshing;

  Future<CurrentUser> login({required String identifier, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/login', data: {'identifier': identifier.trim(), 'password': password});
    await _saveTokens(AuthTokens.fromJson(response.data!));
    return currentUser();
  }

  Future<CurrentUser> currentUser() async {
    final response = await _authorizedGet('/auth/me');
    return CurrentUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<SecuritySession>> securitySessions() async {
    final response = await _authorizedGet('/auth/sessions');
    return (response.data as List<dynamic>).map((item) => SecuritySession.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await _authorizedPostWithBody('/auth/change-password', {'currentPassword': currentPassword, 'newPassword': newPassword});
    await _clearTokens();
  }

  Future<void> revokeSession(String id) async {
    await _authorizedPostWithBody('/auth/revoke-session', {'sessionId': id});
  }

  Future<int> revokeAllSessions() async {
    final response = await _authorizedPost('/auth/revoke-all-sessions');
    final count = (response.data as Map<String, dynamic>)['revokedCount'];
    return count is int ? count : 0;
  }

  Future<StaffWorkspaceView> staffWorkspace() async {
    final response = await _authorizedGet('/staff/me');
    return StaffWorkspaceView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MyPayrollView> myPayroll() async {
    final response = await _authorizedGet('/payroll/me');
    return MyPayrollView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<GuardianProfileView> guardianProfile() async {
    final response = await _authorizedGet('/guardians/me/profile');
    return GuardianProfileView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<GuardianProfileView> updateGuardianProfile({required String firstName, required String lastName, String? address, String? occupation, String? hometown, String? region, required bool preferredSms, required bool preferredPush}) async {
    final response = await _authorizedPatchWithBody('/guardians/me/profile', {'firstName': firstName, 'lastName': lastName, 'address': address, 'occupation': occupation, 'hometown': hometown, 'region': region, 'preferredSms': preferredSms, 'preferredPush': preferredPush});
    return GuardianProfileView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<WardView>> wards() async {
    final response = await _authorizedGet('/students/me/wards');
    return (response.data as List<dynamic>).map((item) => WardView.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }

  Future<List<NotificationView>> notifications({String? status}) async {
    final response = await _authorizedGet('/notifications/me${status == null ? '' : '?status=${Uri.encodeQueryComponent(status)}'}');
    return (response.data as List<dynamic>).map((item) => NotificationView.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }

  Future<void> markNotificationRead(String id) async {
    await _authorizedPatch('/notifications/$id/read');
  }

  Future<int> markAllNotificationsRead() async {
    final response = await _authorizedPost('/notifications/me/read-all');
    return (response.data as Map<String, dynamic>)['updatedCount'] as int? ?? 0;
  }

  Future<List<AnnouncementView>> announcements() async {
    final response = await _authorizedGet('/announcements');
    return (response.data as List<dynamic>).map((item) => AnnouncementView.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }

  Future<List<StationeryItemView>> stationeryCatalog() async {
    final response = await _authorizedGet('/stationery/catalog');
    return (response.data as List<dynamic>).map((item) => StationeryItemView.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }

  Future<AcademicReportView> currentAcademicReport(String studentId) async {
    final response = await _authorizedGet('/academic-reports/students/$studentId/current');
    return AcademicReportView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PublishedAcademicReportView?> currentPublishedAcademicReport(String studentId, String termId) async {
    try {
      final response = await _authorizedGet('/academic-reports/students/$studentId/terms/$termId/publications/current');
      return PublishedAcademicReportView.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<AttendanceSummaryView> studentAttendance(String studentId, {String? termId}) async {
    final path = '/attendance/students/$studentId${termId == null ? '' : '?termId=${Uri.encodeQueryComponent(termId)}'}';
    final response = await _authorizedGet(path);
    return AttendanceSummaryView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<InvoiceView>> studentInvoices(String studentId) async {
    final response = await _authorizedGet('/finance/students/$studentId/invoices');
    return (response.data as List<dynamic>).map((item) => InvoiceView.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }

  Future<List<ReceiptView>> studentReceipts(String studentId) async {
    final response = await _authorizedGet('/finance/students/$studentId/receipts');
    return (response.data as List<dynamic>).map((item) => ReceiptView.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }

  Future<WalletStatementView> studentWallet(String studentId) async {
    final response = await _authorizedGet('/wallets/students/$studentId');
    return WalletStatementView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WalletTopUpView> initiateWalletTopUp({
    required String studentId,
    required String amount,
    required String idempotencyKey,
    String? network,
  }) async {
    final response = await _authorizedPostWithBodyAndHeaders(
      '/wallets/students/' + Uri.encodeComponent(studentId) + '/top-up',
      {
        'amount': amount.trim(),
        if (network != null && network.trim().isNotEmpty) 'network': network.trim(),
      },
      {'Idempotency-Key': idempotencyKey},
    );
    return WalletTopUpView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WalletTopUpView> submitWalletTopUpOtp({
    required String studentId,
    required String paymentId,
    required String otpCode,
    required String idempotencyKey,
    String? network,
    String? sessionId,
  }) async {
    final response = await _authorizedPostWithBodyAndHeaders(
      '/finance/students/' + Uri.encodeComponent(studentId) + '/payments/' + Uri.encodeComponent(paymentId) + '/otp',
      {
        'otpCode': otpCode.trim(),
        if (network != null && network.trim().isNotEmpty) 'network': network.trim(),
        if (sessionId != null && sessionId.trim().isNotEmpty) 'sessionId': sessionId.trim(),
      },
      {'Idempotency-Key': idempotencyKey},
    );
    return WalletTopUpView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaymentPreflightView> paymentPreflight(String studentId, List<String> invoiceIds, {String? amount}) async {
    final response = await _authorizedPostWithBody('/finance/students/$studentId/payment-preflight', {'invoiceIds': invoiceIds, if (amount != null) 'amount': amount});
    return PaymentPreflightView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> createAttendanceSession({required String termId, required String classId, required String subjectId, required DateTime sessionDate, String? periodLabel}) async {
    final response = await _authorizedPostWithBody('/attendance/sessions', {
      'termId': termId,
      'classId': classId,
      'subjectId': subjectId,
      'sessionDate': sessionDate.toIso8601String(),
      if (periodLabel != null && periodLabel.trim().isNotEmpty) 'periodLabel': periodLabel.trim(),
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<TeacherAttendanceRosterView> attendanceRoster(String sessionId) async {
    final response = await _authorizedGet('/attendance/sessions/$sessionId/roster');
    return TeacherAttendanceRosterView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> markAttendance(String sessionId, List<TeacherAttendanceMark> records) async {
    await _authorizedPostWithBody('/attendance/sessions/$sessionId/records', {
      'records': records.map((record) => record.toJson()).toList(growable: false),
    });
  }

  Future<List<AssessmentRosterStudentView>> assessmentRoster({
    required String classId,
    required String termId,
    required String subjectId,
  }) async {
    final response = await _authorizedGet(
      '/assessments/roster?classId=' + Uri.encodeQueryComponent(classId) + '&termId=' + Uri.encodeQueryComponent(termId) + '&subjectId=' + Uri.encodeQueryComponent(subjectId),
    );
    return (response.data as List<dynamic>)
        .map((item) => AssessmentRosterStudentView.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<CreatedAssessmentView> createAssessment({
    required String termId,
    required String subjectId,
    required String title,
    required String type,
    required double maxScore,
    double? weight,
  }) async {
    final data = <String, dynamic>{
      'termId': termId,
      'subjectId': subjectId,
      'title': title.trim(),
      'type': type,
      'maxScore': maxScore,
      if (weight != null) 'weight': weight,
    };
    final response = await _authorizedPostWithBody('/assessments', data);
    return CreatedAssessmentView.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AssessmentResultView>> enterAssessmentResults({
    required String assessmentId,
    required List<Map<String, dynamic>> results,
  }) async {
    final response = await _authorizedPostWithBody(
      '/assessments/' + Uri.encodeComponent(assessmentId) + '/results',
      {'results': results},
    );
    return (response.data as List<dynamic>)
        .map((item) => AssessmentResultView.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
  Future<void> logout() async {
    final refreshToken = await _storage.read(key: _refreshKey);
    try {
      if (refreshToken != null) await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } finally {
      await _clearTokens();
    }
  }

  Future<Response<dynamic>> _authorizedGet(String path) => _authorizedRequest((token) =>
      _dio.get<dynamic>(path, options: Options(headers: {'Authorization': 'Bearer $token'})));

  Future<Response<dynamic>> _authorizedPatch(String path) => _authorizedRequest((token) =>
      _dio.patch<dynamic>(path, options: Options(headers: {'Authorization': 'Bearer $token'})));

  Future<Response<dynamic>> _authorizedPatchWithBody(String path, Map<String, dynamic> data) => _authorizedRequest((token) =>
      _dio.patch<dynamic>(path, data: data, options: Options(headers: {'Authorization': 'Bearer $token'})));

  Future<Response<dynamic>> _authorizedPost(String path) => _authorizedRequest((token) =>
      _dio.post<dynamic>(path, options: Options(headers: {'Authorization': 'Bearer $token'})));

  Future<Response<dynamic>> _authorizedPostWithBody(String path, Map<String, dynamic> data) => _authorizedRequest((token) =>
      _dio.post<dynamic>(path, data: data, options: Options(headers: {'Authorization': 'Bearer $token'})));

  Future<Response<dynamic>> _authorizedPostWithBodyAndHeaders(
    String path,
    Map<String, dynamic> data,
    Map<String, String> headers,
  ) =>
      _authorizedRequest((token) => _dio.post<dynamic>(
            path,
            data: data,
            options: Options(headers: {'Authorization': 'Bearer $token', ...headers}),
          ));

  Future<Response<dynamic>> _authorizedRequest(Future<Response<dynamic>> Function(String token) request) async {
    try {
      return await request(await _accessToken());
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) rethrow;
      await _refreshOnce();
      return request(await _accessToken());
    }
  }

  Future<String> _accessToken() async {
    final token = await _storage.read(key: _accessKey);
    if (token == null || token.isEmpty) throw StateError('No BCI access token is available.');
    return token;
  }

  Future<void> _refreshOnce() async {
    final inFlight = _refreshing;
    if (inFlight != null) {
      await inFlight;
      return;
    }
    final future = _refresh();
    _refreshing = future;
    try {
      await future;
    } finally {
      if (identical(_refreshing, future)) _refreshing = null;
    }
  }

  Future<void> _refresh() async {
    final refreshToken = await _storage.read(key: _refreshKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearTokens();
      throw DioException(requestOptions: RequestOptions(path: '/auth/refresh'), error: 'No refresh token is available.');
    }
    final response = await _dio.post<Map<String, dynamic>>('/auth/refresh', data: {'refreshToken': refreshToken});
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