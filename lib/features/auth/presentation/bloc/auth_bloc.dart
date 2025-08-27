import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/get_interests_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase signUpUseCase;
  final GetInterestsUseCase getInterestsUseCase;

  User? _user;

  AuthBloc({
    required this.signUpUseCase,
    required this.getInterestsUseCase,
  }) : super(AuthInitial()) {
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        _user = User(
          fullName: event.fullName,
          email: event.email,
          password: event.password,
        );
        await signUpUseCase(_user!);
        emit(AuthSuccess(_user!));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LoadInterestsEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final interests = await getInterestsUseCase();
        emit(InterestsLoaded(interests));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<SaveInterestsEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        if (_user == null) {
          emit(AuthFailure('No user found to save interests'));
          return;
        }
        _user!.interests = event.selectedInterests;
        emit(InterestsSavedSuccess(event.selectedInterests));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
