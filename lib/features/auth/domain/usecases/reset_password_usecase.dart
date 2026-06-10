import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  const ResetPasswordUseCase(this.repository);

  Future<void> execute({
    required String nrpNip,
    required String token,
    required String newPassword,
  }) {
    return repository.resetPassword(
      nrpNip: nrpNip,
      token: token,
      newPassword: newPassword,
    );
  }
}
