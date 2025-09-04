part of 'user_cubit.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

class UserActionSuccess extends UserState {
  final String message;
  UserActionSuccess(this.message);
}

class SubscribedSourcesLoaded extends UserState {
  final List<String> sources;
  SubscribedSourcesLoaded(this.sources);
}

class SubscribedTopicsLoaded extends UserState {
  final List<String> topics;
  SubscribedTopicsLoaded(this.topics);
}

class AllTopicsLoaded extends UserState {
  final List<String> topics;
  AllTopicsLoaded(this.topics);
}

class AllSourcesLoaded extends UserState {
  final List<String> sources;
  AllSourcesLoaded(this.sources);
}
