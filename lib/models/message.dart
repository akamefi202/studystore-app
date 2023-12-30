class Message {
  String text;
  String sender;
  DateTime datetime;

  Message({this.text, this.sender, this.datetime});

  static Message fromJson(Map<String, Object> jsonValue) {
    DateTime datetime = DateTime.parse(jsonValue['msg_date']);

    return Message(
        text: jsonValue['message'],
        datetime: datetime,
        sender: jsonValue['sender']);
  }
}
