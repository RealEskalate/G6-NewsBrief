import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_all_sources.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_all_topic.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_subscribed_sources.dart';
import 'package:newsbrief/features/auth/domain/usecases/get_subscribed_topics.dart';
import 'package:newsbrief/features/auth/domain/usecases/subscribe_to_sources.dart';
import 'package:newsbrief/features/auth/domain/usecases/subscrible_to_topics.dart';
import 'package:newsbrief/features/auth/domain/usecases/unsubscribe_from_source.dart';
import 'package:newsbrief/features/auth/domain/usecases/unsubscrible_to_topic.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetSubscribedSources getSubscribedSources;
  final SubscribeToSources subscribeToSources;
  final UnsubscribeFromSource unsubscribeFromSource;
  final GetSubscribedTopics getSubscribedTopics;
  final GetAllTopic getAllTopic;
  final GetAllSources getAllSources;
  final SubscribeToTopics subscribeUseCase;
  final UnsubscribeFromTopic unsubscribeUseCase;

  UserCubit({
    required this.getSubscribedSources,
    required this.subscribeToSources,
    required this.unsubscribeFromSource,
    required this.getSubscribedTopics,
    required this.getAllTopic,
    required this.getAllSources,
    required this.subscribeUseCase,
    required this.unsubscribeUseCase,

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
      emit(SubscribedTopicsLoaded(topics));
    } catch (e) {
      emit(UserError(_msg(e)));
    }
  }

  Future<void> loadAllTopics() async {
    emit(UserLoading());
    try {
      // Get raw topics from your repository
      final topicsData =
          await getAllTopic(); // this returns List<Map<String, dynamic>>

      emit(AllTopicsLoaded(topicsData));
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

  Future<void> subscribe(List<String> topicIds) async {
    emit(TopicLoading());
    try {
      await subscribeUseCase(topicIds);
      emit(TopicActionSuccess("Subscribed successfully"));
    } catch (e) {
      emit(TopicError(e.toString()));
    }
  }

  Future<void> unsubscribe(String topicId) async {
    emit(TopicLoading());
    try {
      await unsubscribeUseCase(topicId);
      emit(TopicActionSuccess("Unsubscribed successfully"));
    } catch (e) {
      emit(TopicError(e.toString()));
    }
  }
}