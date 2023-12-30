class Product {
  int id;
  String name;
  double x;
  double y;
  double width;
  double height;
  double ratio;
  bool available;
  bool ordered;
  List<int> paymentTypeIds;

  Product(
      {this.id,
      this.name = "",
      this.x = 0.0,
      this.y = 0.0,
      this.width = 0.0,
      this.height = 0.0,
      this.ratio = 1.0,
      this.available = false,
      this.ordered = false,
      this.paymentTypeIds});

  static Product fromPositionJson(Map<String, Object> jsonValue) {
    Product product = Product(
        x: jsonValue['x'],
        y: jsonValue['y'],
        width: jsonValue['width'],
        height: jsonValue['height'],
        ratio: jsonValue['ratio'],
        paymentTypeIds: []);
    return product;
  }
}
