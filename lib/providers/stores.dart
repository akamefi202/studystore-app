import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/models/store.dart';

class Stores with ChangeNotifier {
  List<Store> storeList = [];
  int storeId = -1;

  Future<void> getStores() async {
    var url = Uri.parse(serverUrl + '/api/store/list');
    var body = jsonEncode({"key": "", "offset": 0, "pagesize": pageSizeLimit});

    var response = await http.post(url, body: body, headers: {"Content-Type": "application/json"});
    var responseBody = jsonDecode(response.body);

    List<Object> stores = responseBody['data'];
    this.storeList = [];

    stores.forEach((store) {
      Map<String, Object> storeData = store;
      this.storeList.add(Store.fromJson(storeData));
    });

    if (this.storeList.length > 0) {
      this.storeId = this.storeList[0].id;
    }

    notifyListeners();
  }
}
