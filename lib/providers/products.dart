import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/constants/product_positions.dart';
import 'package:studystore_app/models/payment_type.dart';
import 'package:studystore_app/models/product.dart';
import 'package:studystore_app/models/store.dart';
import 'package:studystore_app/modules/string.dart';

class Products with ChangeNotifier {
  List<Product> seatList = [];
  List<Product> meetingRoomList = [];

  Future<void> getProducts(int storeId) async {
    // get products data from server
    var url = Uri.parse(serverUrl + '/api/product/list');
    var body = jsonEncode({"key": "", "offset": 0, "pagesize": pageSizeLimit, "store_id": storeId});

    var response = await http.post(url, body: body, headers: {"Content-Type": "application/json"});
    var responseBody = jsonDecode(response.body);

    // initialize seat list with position
    this.seatList = [];
    seatPositions.forEach((element) {
      this.seatList.add(Product.fromPositionJson(element));
    });

    // initialize meeting room list with position
    this.meetingRoomList = [];
    meetingRoomPositions.forEach((element) {
      this.meetingRoomList.add(Product.fromPositionJson(element));
    });

    // initialize product list with id, name and etc
    // get available payment types for each product
    List<Object> products = responseBody['data'];
    products.forEach((element) {
      try {
        // get type of product('seat' or 'meeting room') and product number
        Map<String, Object> p = element;
        String productName = p['name'];
        List<String> parts = productName.split("-");

        String productType = parts[0];
        int productNo = int.parse(parts[1]);

        if ((productType == '卡座' || productType == 'VIP') && productNo <= this.seatList.length) {
          this.seatList[productNo - 1].id = p['id'];
          this.seatList[productNo - 1].name = p['name'];
          this.seatList[productNo - 1].paymentTypeIds = this.getIdList(p['paytype_ids']);
        } else if (productType == '会议室' && productNo <= this.meetingRoomList.length) {
          this.meetingRoomList[productNo - 1].id = p['id'];
          this.meetingRoomList[productNo - 1].name = p['name'];
          this.meetingRoomList[productNo - 1].paymentTypeIds = this.getIdList(p['paytype_ids']);
        }
      } catch (error) {
        print(error);
      }
    });

    notifyListeners();
  }

  List<int> getIdList(String str) {
    if (str == '' || str == null) {
      return [];
    }

    List<String> idStrList = str.split(',');
    List<int> idList = [];

    idStrList.forEach((element) {
      idList.add(int.parse(element));
    });

    return idList;
  }

  // find availabe products by selected payment type
  void findAvailableProducts(PaymentType paymentType) {
    this.seatList.forEach((element) {
      if (paymentType != null && element.paymentTypeIds.contains(paymentType.id)) {
        element.available = true;
      } else {
        element.available = false;
      }
    });

    this.meetingRoomList.forEach((element) {
      if (paymentType != null && element.paymentTypeIds.contains(paymentType.id)) {
        element.available = true;
      } else {
        element.available = false;
      }
    });
  }

  // find ordered products between from time and to time
  Future<bool> findCurrentOrder(
      String phone, int storeId, DateTime fromTime, DateTime toTime) async {
    print('findCurrentOrder');
    // get orders data between from time and to time
    var url = Uri.parse(serverUrl + '/api/order/rangelist');
    var body = jsonEncode({
      "from_date": getStringFromDateTime(fromTime),
      "to_date": getStringFromDateTime(toTime),
      "store_id": storeId,
      "user_phone": phone
    });
    print(body);

    var response = await http.post(url, body: body, headers: {"Content-Type": "application/json"});
    var responseBody = jsonDecode(response.body);

    List<Object> orders = responseBody['data'];
    print(orders.length);

    return orders.length != 0;
  }

  // find ordered products between from time and to time
  Future<void> findOrderedProducts(int storeId, DateTime fromTime, DateTime toTime) async {
    // get orders data between from time and to time
    var url = Uri.parse(serverUrl + '/api/order/rangelist');
    var body = jsonEncode({
      "from_date": getStringFromDateTime(fromTime),
      "to_date": getStringFromDateTime(toTime),
      "store_id": storeId,
    });

    var response = await http.post(url, body: body, headers: {"Content-Type": "application/json"});
    var responseBody = jsonDecode(response.body);

    List<Object> orders = responseBody['data'];

    // initialize ordered field of all products
    this.seatList.forEach((element) {
      element.ordered = false;
    });
    this.meetingRoomList.forEach((element) {
      element.ordered = false;
    });

    // find ordered products
    orders.forEach((order) {
      try {
        Map<String, Object> jsonOrder = order;
        String productName = jsonOrder['product_name'];
        List<String> parts = productName.split('-');

        String productType = parts[0];
        int productNo = int.parse(parts[1]);

        if ((productType == '卡座' || productType == 'VIP') && productNo <= this.seatList.length) {
          this.seatList[productNo - 1].ordered = true;
        } else if (productType == '会议室' && productNo <= this.meetingRoomList.length) {
          this.meetingRoomList[productNo - 1].ordered = true;
        }
      } catch (error) {
        print(error);
      }
    });
  }

  int getUnorderedSeatCount() {
    int count = 0;

    this.seatList.forEach((element) {
      if (element.ordered == false) {
        count++;
      }
    });

    return count;
  }

  int getUnorderedMeetingRoomCount() {
    int count = 0;

    this.meetingRoomList.forEach((element) {
      if (element.ordered == false) {
        count++;
      }
    });

    return count;
  }
}
