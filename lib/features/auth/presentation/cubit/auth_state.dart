import 'package:equatable/equatable.dart';
import 'package:newsbrief/features/auth/domain/entities/auth_entities.dart';


abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthEmailActionSuccess extends AuthState {
  final String message; // e.g., "Verification email sent"
  const AuthEmailActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthLoggedOut extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class InterestsLoaded extends AuthState {
  final List<String> interests;
  const InterestsLoaded(this.interests);

  @override
  List<Object?> get props => [interests];
}

class InterestsSavedSuccess extends AuthState {
  final List<String> selectedInterests;
  const InterestsSavedSuccess(this.selectedInterests);

  @override
  List<Object?> get props => [selectedInterests];
}
