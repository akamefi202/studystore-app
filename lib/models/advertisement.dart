import 'package:flutter/material.dart';
import 'package:studystore_app/constants/config.dart';

class Advertisement {
  String imageUrl;

  Advertisement({this.imageUrl});

  static Advertisement fromJson(Map<String, Object> jsonValue) {
    return Advertisement(imageUrl: serverUrl + '/' + jsonValue['image_url']);
  }
}
