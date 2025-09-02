import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/auth/domain/usecases/forgot_password.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_interests_usecase.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_me.dart';
import 'package:newsbrief/features/auth/domain/usecases/login_user.dart';
import 'package:newsbrief/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:newsbrief/features/auth/domain/usecases/logout.dart';
import 'package:newsbrief/features/auth/domain/usecases/register_user.dart';
import 'package:newsbrief/features/auth/domain/usecases/request_verification_email.dart';
import 'package:newsbrief/features/auth/domain/usecases/reset_password.dart';
import 'package:newsbrief/features/auth/domain/usecases/verify_email.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final GetMe getMe;
  final Logout logout;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final VerifyEmail verifyEmail;
  final RequestVerificationEmail requestVerificationEmail;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final GetInterestsUseCase getInterestsUseCase;

  AuthCubit({
    required this.loginUser,
    required this.registerUser,
    required this.getMe,
    required this.logout,
    required this.forgotPassword,
    required this.resetPassword,
    required this.verifyEmail,
    required this.requestVerificationEmail,
    required this.loginWithGoogleUseCase,
    required this.getInterestsUseCase,
  }) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      // loginUser now returns AuthResponseEntity (user + tokens)
      final authResponse = await loginUser(email: email, password: password);

      if (authResponse.user.isVerified == false) {
        emit(const AuthEmailActionSuccess('Please verify your email.'));
      }
      // Cache tokens locally if needed (already done in repository)
      // emit authenticated state with user entity
      emit(AuthAuthenticated(authResponse.user));
    } catch (e) {
      emit(AuthError(_msg(e)));
    }
  }

  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    try {
      await registerUser(email: email, password: password, name: name);

      emit(
        const AuthEmailActionSuccess('Registered. Please verify your email.'),
      );

      final response = await loginUser(email: email, password: password);
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      emit(AuthError(_msg(e)));
    }
  }

  Future<void> loadCurrentUser() async {
    emit(AuthLoading());
    try {
      final user = await getMe();
      emit(AuthAuthenticated(user.user));
    } catch (e) {
      emit(AuthError(_msg(e)));
    }
  }

  Future<void> sendVerificationEmail(String email) async {
    emit(AuthLoading());
    try {
      await requestVerificationEmail(email: email);
      emit(const AuthEmailActionSuccess('Verification email sent.'));
      final user = await getMe();
      emit(AuthAuthenticated(user.user));
    } catch (e) {
      emit(AuthError(_msg(e)));
    }
  }

  Future<void> verifyEmailRequest(String token) async {
    emit(AuthLoading());
    try {
      await verifyEmail(token: token); // now returns Tokens
      final user = await getMe();
      emit(AuthAuthenticated(user.user));
    } catch (e) {
      emit(AuthError(_msg(e)));
    }
  }

  Future<void> forgotPasswordUsecase(String email) async {
    emit(AuthLoading());
    try {
      await forgotPassword(email: email);
      emit(const AuthEmailActionSuccess('Password reset email sent.'));
    } catch (e) {
      emit(AuthError(_msg(e)));
    }
  }

  Future<void> resetPasswordUsecase(String token, String password) async {
    emit(AuthLoading());
    try {
      await resetPassword(token: token, password: password);
      emit(const AuthEmailActionSuccess('Password reset successful.'));
    } catch (e) {
      emit(AuthError(_msg(e)));
    }
  }

  Future<void> logoutUsecase(String refreshToken) async {
    emit(AuthLoading());
    try {
      await logout(refreshToken: refreshToken);
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError(_msg(e)));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final res = await loginWithGoogleUseCase();
      emit(AuthAuthenticated(res.user));
    } catch (e) {
      emit(AuthError(_msg(e)));
    }
  }

  Future<void> loadInterests() async {
    emit(AuthLoading());
    try {
      final interests = await getInterestsUseCase();
      emit(InterestsLoaded(interests));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> saveInterests(List<String> selectedInterests) async {
    emit(AuthLoading());
    try {
      final user = await getMe();
      user.interest = selectedInterests;
      emit(InterestsSavedSuccess(selectedInterests));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');
}
