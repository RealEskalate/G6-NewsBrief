import 'package:flutter_bloc/flutter_bloc.dart';
import '../../datasource/datasources/local_admin_data.dart';
import '../../domain/entities/source.dart';
import '../../domain/entities/topic.dart';


part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(AdminInitial());

  // ---- Topics ----
  Future<void> loadAllTopics() async {
    emit(AdminLoading());
    try {
      final topics = await LocalAdminData.getTopics();
      emit(AllTopicsLoaded(topics));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> addTopic(Topic topic) async {
    emit(AdminLoading());
    try {
      await LocalAdminData.addTopic(topic);
      await loadAllTopics();
      emit(AdminActionSuccess("Topic added!"));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  // ---- Sources ----
  Future<void> loadAllSources() async {
    emit(AdminLoading());
    try {
      final sources = await LocalAdminData.getSources();
      emit(AllSourcesLoaded(sources));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> addSource(Source source) async {
    emit(AdminLoading());
    try {
      await LocalAdminData.addSource(source);
      await loadAllSources();
      emit(AdminActionSuccess("Source added!"));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
