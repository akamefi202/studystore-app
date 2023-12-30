import 'package:studystore_app/constants/config.dart';

class PaymentType {
  int id;
  String name;
  String type;
  int roomType; // 0: seat, 1: meeting room
  double price;
  double maxPrice;
  DateTime fromTime;
  DateTime toTime;
  String remarks;
  String imageUrl;

  PaymentType(
      {this.id = -1,
      this.name = '',
      this.type = 'hour',
      this.roomType = 0,
      this.price = 0.0,
      this.maxPrice = 0.0,
      this.fromTime,
      this.toTime,
      this.remarks = '',
      this.imageUrl = ''});

  static PaymentType fromJson(Map<String, Object> jsonValue) {
    DateTime finalFromTime;
    DateTime finalToTime;

    finalFromTime = getTimefromString(jsonValue['from_time']);
    finalToTime = getTimefromString(jsonValue['to_time']);

    return PaymentType(
        id: jsonValue['id'],
        name: jsonValue['name'],
        type: jsonValue['types'],
        roomType: jsonValue['room_type'],
        price: double.parse(jsonValue['price']),
        maxPrice: jsonValue['max_price'] == null ? 0.0 : double.parse(jsonValue['max_price']),
        fromTime: finalFromTime,
        toTime: finalToTime,
        remarks: jsonValue['remarks'],
        imageUrl: serverUrl + '/' + jsonValue['image_url']);
  }

  static DateTime getTimefromString(String timeString) {
    List<String> parts = timeString.split(':');
    return DateTime(2021, 1, 1, int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}
