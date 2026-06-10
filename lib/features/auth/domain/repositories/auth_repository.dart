import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String nrpNip,
    required String password,
    required String fcmToken,
  });

  Future<bool> isLoggedIn();

  Future<void> logout();

  Future<void> updatePassword({required String newPassword});

  Future<void> resetPassword({
    required String nrpNip,
    required String token,
    required String newPassword,
  });

  Future<bool> verifyResetToken(String nrpNip, String token);

  Future<String> uploadProfilePhoto(String filePath);

  Future<void> deleteProfilePhoto();
}
