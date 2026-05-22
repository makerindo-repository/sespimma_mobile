import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<UpdateProfilePhotoRequested>(_onUpdateProfilePhotoRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await loginUseCase.execute(
        nrp: event.nrp,
        password: event.password,
        fcmToken: event.fcmToken,
      );

      emit(AuthSuccess(user));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(errorMessage));
    }
  }

  void _onUpdateProfilePhotoRequested(
    UpdateProfilePhotoRequested event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthSuccess) {
      final currentUser = (state as AuthSuccess).user;
      final updatedUser = currentUser.copyWith(
        profilePhoto: event.photoPath,
        clearProfilePhoto: event.photoPath == null,
      );
      emit(AuthSuccess(updatedUser));
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthSuccess) {
      final user = (state as AuthSuccess).user;
      emit(AuthLoading());
      await Future.delayed(const Duration(milliseconds: 1200));

      if (event.oldPassword != 'password123') {
        emit(AuthFailure('Password lama yang Anda masukkan salah.'));
        await Future.delayed(const Duration(milliseconds: 100));
        emit(AuthSuccess(user));
        return;
      }

      emit(AuthSuccess(user));
    }
  }
}
