import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/models/payment_type.dart';
import 'package:studystore_app/models/product.dart';
import 'package:studystore_app/modules/string.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/providers/stores.dart';

class StoreSelectionScreen extends StatefulWidget {
  static const routeName = 'screens/store_selection';

  StoreSelectionScreen({Key key}) : super(key: key);
  @override
  _StoreSelectionScreenState createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(lang.moreStores[lang.langMode]),
        ),
        body: Container(
            child: Center(child: Text(lang.moreStores[lang.langMode]))));
  }
}
