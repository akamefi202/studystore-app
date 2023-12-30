import 'package:studystore_app/constants/config.dart';

class LearningBlog {
  String content;
  String title;
  String videoUrl;
  DateTime date;
  String type;

  LearningBlog({this.content = '', this.title = '', this.videoUrl = '', this.date, this.type = ''});

  static LearningBlog fromJson(Map<String, Object> jsonValue) {
    return LearningBlog(
        content: jsonValue['contents'],
        title: jsonValue['title'],
        videoUrl: jsonValue['video_url'],
        date: DateTime.parse(jsonValue['updatedAt']),
        type: jsonValue['type_name']);
  }
}
