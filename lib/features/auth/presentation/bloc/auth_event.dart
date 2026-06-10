import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String nrpNip;
  final String password;
  final String fcmToken;

  const LoginSubmitted({
    required this.nrpNip,
    required this.password,
    required this.fcmToken,
  });

  @override
  List<Object> get props => [nrpNip, password, fcmToken];
}

class UpdateProfilePhotoRequested extends AuthEvent {
  final String? photoPath;

  const UpdateProfilePhotoRequested(this.photoPath);

  @override
  List<Object> get props => [photoPath ?? ''];
}

class ChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [oldPassword, newPassword];
}

class ResetPasswordRequested extends AuthEvent {
  final String nrpNip;
  final String token;
  final String newPassword;

  const ResetPasswordRequested({
    required this.nrpNip,
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object> get props => [nrpNip, token, newPassword];
}
