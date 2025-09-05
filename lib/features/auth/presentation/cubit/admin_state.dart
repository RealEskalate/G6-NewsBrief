part of 'admin_cubit.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

class AdminActionSuccess extends AdminState {
  final String message;
  AdminActionSuccess(this.message);
}

class AllTopicsLoaded extends AdminState {
  final List<Topic> topics;
  AllTopicsLoaded(this.topics);
}

class AllSourcesLoaded extends AdminState {
  final List<Source> sources;
  AllSourcesLoaded(this.sources);
}
