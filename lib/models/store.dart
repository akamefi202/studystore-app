class Store {
  int id;
  String name;
  DateTime fromTime;
  DateTime toTime;

  Store({this.id, this.name, this.fromTime, this.toTime});

  static Store fromJson(Map<String, Object> jsonValue) {
    DateTime fromTime = getTimefromString(jsonValue['from_time']);
    DateTime toTime = getTimefromString(jsonValue['to_time']);

    return Store(
        id: jsonValue['id'],
        name: jsonValue['name'],
        fromTime: fromTime,
        toTime: toTime);
  }

  static DateTime getTimefromString(String timeString) {
    List<String> parts = timeString.split(':');
    return DateTime(2021, 1, 1, int.parse(parts[0]), int.parse(parts[1]),
        int.parse(parts[2]));
  }
}
