import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';


abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class InterestsLoaded extends AuthState {
  final List<String> interests;
  InterestsLoaded(this.interests);

  @override
  List<Object?> get props => [interests];
}

class InterestsSavedSuccess extends AuthState {
  final List<String> selectedInterests;
  InterestsSavedSuccess(this.selectedInterests);

  @override
  List<Object?> get props => [selectedInterests];
}