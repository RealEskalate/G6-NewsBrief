part of 'user_cubit.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}


class TopicLoading extends UserState {}

class TopicActionSuccess extends UserState {
  final String message;
  TopicActionSuccess(this.message);
}

class TopicError extends UserState {
  final String message;
  TopicError(this.message);
}

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
  final List<Map<String, dynamic>> topics;
  SubscribedTopicsLoaded(this.topics);
}

class AllTopicsLoaded extends UserState {
  final List<Map<String, dynamic>> topics;
  AllTopicsLoaded(this.topics);
}

class AllSourcesLoaded extends UserState {
  final List<Map<String, dynamic>> sources;
  AllSourcesLoaded(this.sources);
}

class UserLoaded extends UserState {
  final List<Map<String, dynamic>> sources;
  final List<Map<String, dynamic>> topics;

  UserLoaded({required this.sources, required this.topics});
}
