import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_all_sources.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_all_topic.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_subscribed_sources.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_subscribed_topics.dart';
import 'package:newsbrief/features/auth/domain/usecases/subscribe_to_sources.dart';
import 'package:newsbrief/features/auth/domain/usecases/unsubscribe_from_source.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetSubscribedSources getSubscribedSources;
  final SubscribeToSources subscribeToSources;
  final UnsubscribeFromSource unsubscribeFromSource;
  final GetSubscribedTopics getSubscribedTopics;
  final GetAllTopic getAllTopic;
  final GetAllSources getAllSources;

  UserCubit({
    required this.getSubscribedSources,
    required this.subscribeToSources,
    required this.unsubscribeFromSource,
    required this.getSubscribedTopics,
    required this.getAllTopic,
    required this.getAllSources,
  }) : super(UserInitial());

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<void> loadSubscribedSources() async {
    emit(UserLoading());
    try {
      final sources = await getSubscribedSources();
      emit(SubscribedSourcesLoaded(sources));
    } catch (e) {
      emit(UserError(_msg(e)));
    }
  }

  Future<void> addSources(String sourceSlug) async {
    emit(UserLoading());
    try {
      await subscribeToSources(sourceSlug: sourceSlug);
      emit(UserActionSuccess("Subscribed to $sourceSlug"));
      await loadSubscribedSources();
    } catch (e) {
      emit(UserError(_msg(e)));
    }
  }

  Future<void> removeSources(String sourceSlug) async {
    emit(UserLoading());
    try {
      await unsubscribeFromSource(sourceSlug: sourceSlug);
      emit(UserActionSuccess("Unsubscribed from $sourceSlug"));
      await loadSubscribedSources();
    } catch (e) {
      emit(UserError(_msg(e)));
    }
  }

  Future<void> loadSubscribedTopics() async {
    emit(UserLoading());
    try {
      final topics = await getSubscribedTopics();
      emit(SubscribedSourcesLoaded(topics));
    } catch (e) {
      emit(UserError(_msg(e)));
    }
  }

  Future<void> addTopic(String topicSlug) async {
    emit(UserLoading());
    try {
      // final SubscribeToTopics();
    } catch (e) {
      emit(UserError(_msg(e)));
    }
  }

  Future<void> removeTopic(String topicSlug) async {
    emit(UserLoading());
    try {
      // final SubscribeToTopics();
    } catch (e) {
      emit(UserError(_msg(e)));
    }
  }

  Future<void> loadAllTopics() async {
    emit(UserLoading());
    try {
      final topic = await getSubscribedTopics();
      emit(SubscribedTopicsLoaded(topic));
    } catch (e) {
      emit(UserError(_msg(e)));
    }
  }

  Future<void> loadAllSources() async {
    emit(UserLoading());
    try {
      final sources = await getAllSources();
      emit(AllSourcesLoaded(sources));
    } catch (e) {
      emit(UserError(_msg(e)));
    }
  }

  void saveInterests(List<String> interests) async {
    emit(UserLoading());
    try {
      saveInterests(interests);
      emit(UserActionSuccess("Interests saved!"));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}