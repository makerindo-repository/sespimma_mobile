import 'dart:io';

import 'package:dio/dio.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> updatePassword(String newPassword);
  Future<void> resetPassword(String nrpNip, String token, String newPassword);
  Future<bool> verifyResetToken(String nrpNip, String token);
  Future<String> uploadProfilePhoto(String filePath);
  Future<void> deleteProfilePhoto();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  const AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await dio.post('/login', data: request.toJson());

      if (response.statusCode == 200 && response.data['status'] == true) {
        return LoginResponse.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Login gagal');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        throw Exception(e.response!.data['message'] ?? 'Server error');
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout');
      }

      throw Exception(e.message ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final response = await dio.post(
        '/update_password',
        data: {'new_password': newPassword},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          response.data?['message'] ?? 'Gagal memperbarui password',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        throw Exception(
          e.response!.data['message'] ?? 'Gagal memperbarui password',
        );
      }
      throw Exception(e.message ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> resetPassword(
    String nrpNip,
    String token,
    String newPassword,
  ) async {
    try {
      final response = await dio.post(
        '/reset_password',
        data: {'nrp_nip': nrpNip, 'token': token, 'password': newPassword},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data?['message'] ?? 'Gagal reset password');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        throw Exception(e.response!.data['message'] ?? 'Gagal reset password');
      }
      throw Exception(e.message ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<bool> verifyResetToken(String nrpNip, String token) async {
    try {
      final response = await dio.post(
        '/verify_reset_token',
        data: {'nrp_nip': nrpNip, 'token': token},
      );

      return response.statusCode == 200 && response.data['status'] == true;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        throw Exception(e.response!.data['message'] ?? 'Verifikasi gagal');
      }
      throw Exception(e.message ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> uploadProfilePhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          filePath,
          filename: File(filePath).uri.pathSegments.last,
        ),
      });
      final response = await dio.post(
        '/me/photo',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data']['photo_url'] as String;
      }
      throw Exception(response.data['message'] ?? 'Gagal mengunggah foto');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        throw Exception(e.response!.data['message'] ?? 'Gagal mengunggah foto');
      }
      throw Exception(e.message ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteProfilePhoto() async {
    try {
      await dio.delete('/me/photo');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        throw Exception(e.response!.data['message'] ?? 'Gagal menghapus foto');
      }
      throw Exception(e.message ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
