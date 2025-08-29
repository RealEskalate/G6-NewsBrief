import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String password;

  SignUpEvent(this.fullName, this.email, this.password);

  @override
  List<Object?> get props => [fullName, email, password];
}
class LoginEvent extends AuthEvent { // Add LoginEvent
  final String email;
  final String password;

  LoginEvent({
    required this.email,
    required this.password,
  });
}

class SignUpWithGoogleEvent extends AuthEvent {}
class LoginWithGoogleEvent extends AuthEvent {} 
class LoadInterestsEvent extends AuthEvent {}

class SaveInterestsEvent extends AuthEvent {
  final List<String> selectedInterests;
  SaveInterestsEvent(this.selectedInterests);

  @override
  List<Object?> get props => [selectedInterests];
}