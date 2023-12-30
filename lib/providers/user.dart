import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class User with ChangeNotifier {
  int id = -1;
  String name = '';
  String username = '';
  String imageUrl = '';
  String phone = '';
  double currentBalance = 0;
  int freeHours = 0;
  String token = '';
  bool usedExpCard = false;

  Future<bool> updateUser() async {
    print('updateUser');

    if (this.token == '') {
      return false;
    }

    var url = Uri.parse(serverUrl + '/api/user/info');
    var body = jsonEncode({"id": this.id});
    print(body);

    var response = await http.post(url,
        body: body, headers: {"Content-Type": "application/json", "x-access-token": this.token});
    var responseBody = jsonDecode(response.body);
    print(response.body);

    Map<String, Object> responseData = responseBody['data'];
    if (responseData['auth'] == false) {
      return false;
    }

    this.name = responseData['name'];
    this.username = responseData['username'];
    this.imageUrl = responseData['image_url'];
    if (this.imageUrl == null) {
      this.imageUrl = '';
    }
    this.phone = responseData['phone'];
    this.currentBalance = double.parse(responseData['money']);
    this.freeHours = responseData['hours'];
    this.usedExpCard = responseData['used_experience_card'] != 0;

    notifyListeners();
    return true;
  }

  Future<Map<String, Object>> signIn(String phone, String code) async {
    var url = Uri.parse(serverUrl + '/api/user/phone_sign');
    var body = jsonEncode({"phone": phone, "secretkey": code});

    var response = await http.post(url, body: body, headers: {"Content-Type": "application/json"});
    var responseBody = jsonDecode(response.body);

    if (responseBody['code'] == 200) {
      this.id = responseBody['id'];
      this.name = responseBody['name'];
      this.username = responseBody['username'];
      this.imageUrl = responseBody['image_url'];
      if (this.imageUrl == null) {
        this.imageUrl = '';
      }
      this.phone = phone; //responseBody['phone']
      this.token = responseBody['accessToken'];
      this.currentBalance = double.parse(responseBody['money']);
      this.freeHours = responseBody['hours'];
      this.usedExpCard = responseBody['used_experience_card'] != 0;
    }

    notifyListeners();
    return responseBody;
  }

  void signOut() {
    this.id = -1;
    this.name = '';
    this.username = '';
    this.imageUrl = '';
    this.phone = '';
    this.currentBalance = 0;
    this.freeHours = 0;
    this.token = '';
    this.usedExpCard = false;

    notifyListeners();
  }

  Future<void> recharge(int amount) async {
    var url = Uri.parse(serverUrl + '/api/charge/create');
    var body = jsonEncode({"user_phone": this.phone, "money": amount});

    var response = await http.post(url,
        body: body, headers: {"Content-Type": "application/json", "x-access-token": this.token});
    var responseBody = jsonDecode(response.body);

    if (responseBody['code'] == 200) {
      this.currentBalance = double.parse(responseBody['user_money'].toString());
      this.freeHours = int.parse(responseBody['user_hours'].toString());
    }

    notifyListeners();
  }

  Future<void> updateCurrentBalance(double newBalance) async {
    this.currentBalance = newBalance;

    notifyListeners();
  }

  void log() {
    print('********** user **********');
    print('id: ' + this.id.toString());
    print('name: ' + this.name);
    print('username: ' + this.username);
    print('imageUrl: ' + this.imageUrl);
    print('phone: ' + this.phone);
    print('token: ' + this.token);
    print('currentBalance: ' + this.currentBalance.toString());
    print('freeHours: ' + this.freeHours.toString());
    print('usedExpCard: ' + this.usedExpCard.toString());
  }

  Future<Map<String, Object>> updateName(String name) async {
    // save name
    this.name = name;

    var url = Uri.parse(serverUrl + '/api/user/update');
    var request = http.MultipartRequest('POST', url);
    //request.fields['id'] = this.userId.toString();
    request.fields['phone'] = this.phone;
    request.fields['name'] = this.name;

    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['x-access-token'] = this.token;

    var response = await request.send();
    var responseBody = jsonDecode(await response.stream.bytesToString());

    notifyListeners();
    return responseBody;
  }

  Future<Map<String, Object>> updatePassword(String password) async {
    var url = Uri.parse(serverUrl + '/api/user/update');
    var request = http.MultipartRequest('POST', url);
    //request.fields['id'] = this.userId.toString();
    request.fields['phone'] = this.phone;
    request.fields['password'] = password;

    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['x-access-token'] = this.token;

    var response = await request.send();
    var responseBody = jsonDecode(await response.stream.bytesToString());

    notifyListeners();
    return responseBody;
  }
}
