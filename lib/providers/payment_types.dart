import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/models/payment_type.dart';

class PaymentTypes with ChangeNotifier {
  List<PaymentType> paymentTypeList = [];

  // get payment types from database
  Future<void> getPaymentTypes(int storeId) async {
    var url = Uri.parse(serverUrl + '/api/paytype/list');
    var body = jsonEncode({"key": "", "offset": 0, "pagesize": pageSizeLimit, "store_id": storeId});

    var response = await http.post(url, body: body, headers: {"Content-Type": "application/json"});
    var responseBody = jsonDecode(response.body);

    List<Object> pts = responseBody['data'];
    this.paymentTypeList = [];

    pts.forEach((element) {
      Map<String, Object> pt = element;
      this.paymentTypeList.add(PaymentType.fromJson(pt));
    });
  }

  List<PaymentType> getSeatPaymentTypes() {
    return this.paymentTypeList.where((element) => element.roomType == 0).toList();
  }

  List<PaymentType> getMeetingRoomPaymentTypes() {
    return this.paymentTypeList.where((element) => element.roomType == 1).toList();
  }
}
