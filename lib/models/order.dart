class Order {
  int id;
  int productId;
  String productName;
  DateTime date;
  DateTime fromTime;
  DateTime toTime;
  double price;
  bool switchOn;
  int paymentTypeId;
  String paymentTypeName;
  int pause;

  Order(
      {this.id,
      this.productId,
      this.productName,
      this.date,
      this.fromTime,
      this.toTime,
      this.price,
      this.switchOn,
      this.paymentTypeId,
      this.paymentTypeName,
      this.pause});

  static Order fromJson(Map<String, Object> jsonValue) {
    DateTime fromDate = DateTime.parse(jsonValue['from_date']);
    DateTime toDate = DateTime.parse(jsonValue['to_date']);

    return Order(
        id: jsonValue['id'],
        productId: jsonValue['product_id'],
        productName: jsonValue['product_name'],
        date: DateTime(fromDate.year, fromDate.month, fromDate.day),
        fromTime: fromDate,
        toTime: toDate,
        price: double.parse(jsonValue['total_price']),
        switchOn: jsonValue['is_switch'] == 0 || jsonValue['is_switch'] == null ? false : true,
        paymentTypeId: jsonValue['paytype_id'],
        paymentTypeName: jsonValue['paytype_name'],
        pause: jsonValue['is_pause']);
  }
}
