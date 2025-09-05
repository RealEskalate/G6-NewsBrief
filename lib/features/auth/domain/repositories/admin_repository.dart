import '../../../news/datasource/models/news_model.dart';
import '../entities/source.dart';
import '../entities/topic.dart';

abstract class AdminRepository {
  Future<void> createTopic(Topic topic);
  Future<void> createSource(Source source);

}
