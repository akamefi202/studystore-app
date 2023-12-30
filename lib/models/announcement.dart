import 'package:studystore_app/constants/config.dart';

class Announcement {
  String content;
  String title;
  String imageUrl;
  DateTime date;

  Announcement({this.content, this.title, this.imageUrl, this.date});

  static Announcement fromJson(Map<String, Object> jsonValue) {
    return Announcement(
        content: jsonValue['contents'],
        title: jsonValue['title'],
        imageUrl: serverUrl + '/' + jsonValue['image_url'],
        date: DateTime.parse(jsonValue['updatedAt']));
  }
}
