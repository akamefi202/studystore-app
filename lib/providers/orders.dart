import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/models/order.dart';

class Orders with ChangeNotifier {
  List<Order> orderList = [];

  Future<void> getOrders(String token) async {
    print('getOrders');
    var url = Uri.parse(serverUrl + '/api/order/list');
    var body = jsonEncode({"key": "", "offset": 0, "pagesize": pageSizeLimit});

    var response = await http.post(url,
        body: body, headers: {"Content-Type": "application/json", "x-access-token": token});
    var responseBody = jsonDecode(response.body);

    List<Object> orders = responseBody['data'];
    this.orderList = [];

    orders.forEach((element) {
      Map<String, Object> order = element;
      this.orderList.add(Order.fromJson(order));
    });

    notifyListeners();
  }
}
