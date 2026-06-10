import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.updatePasswordUseCase,
    required this.resetPasswordUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<UpdateProfilePhotoRequested>(_onUpdateProfilePhotoRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await loginUseCase.execute(
        nrpNip: event.nrpNip,
        password: event.password,
        fcmToken: event.fcmToken,
      );

      emit(AuthSuccess(user));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onUpdateProfilePhotoRequested(
    UpdateProfilePhotoRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthSuccess) return;
    final currentUser = (state as AuthSuccess).user;
    emit(AuthLoading());
    try {
      String? newPhotoUrl;
      if (event.photoPath != null) {
        newPhotoUrl = await authRepository.uploadProfilePhoto(event.photoPath!);
      } else {
        await authRepository.deleteProfilePhoto();
      }
      final updatedUser = currentUser.copyWith(
        profilePhoto: newPhotoUrl,
        clearProfilePhoto: event.photoPath == null,
      );
      emit(AuthSuccess(updatedUser));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      emit(AuthSuccess(currentUser));
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthSuccess) {
      final user = (state as AuthSuccess).user;
      emit(AuthLoading());

      try {
        await updatePasswordUseCase.execute(newPassword: event.newPassword);
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
        emit(AuthSuccess(user));
      }
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await resetPasswordUseCase.execute(
        nrpNip: event.nrpNip,
        token: event.token,
        newPassword: event.newPassword,
      );
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      emit(AuthInitial());
    }
  }
}
