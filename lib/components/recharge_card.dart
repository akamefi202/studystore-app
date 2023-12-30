import 'dart:convert';

import 'package:currencies/currencies.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/components/announcement_view.dart';
import 'package:studystore_app/modules/string.dart' as stringModule;
import 'package:studystore_app/models/order.dart';
import 'package:studystore_app/models/payment_type.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/constants/colors.dart';
import 'package:studystore_app/components/rounded_button.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/providers/products.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/screens/recharge.dart';
import 'package:studystore_app/screens/sign_in.dart';

class RechargeCard extends StatefulWidget {
  RechargeCard({Key key}) : super(key: key);
  @override
  _RechargeCardState createState() => _RechargeCardState();
}

class _RechargeCardState extends State<RechargeCard> {
  String token = '';

  @override
  void initState() {
    super.initState();

    this.token = Provider.of<User>(context, listen: false).token;
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Ink(
        width: double.infinity,
        height: data.size.height * 0.2,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(0, 0))],
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.blue),
        child: InkWell(
            onTap: () {
              if (context.read<User>().token == '') {
                Navigator.of(context).pushNamed(SignInScreen.routeName);
                return;
              }

              Navigator.of(context).pushNamed(RechargeScreen.routeName);
            },
            overlayColor: MaterialStateProperty.all(Color(0x80ffffff)),
            child: Stack(children: [
              Center(
                  child: Text(lang.recharge[lang.langMode],
                      style: TextStyle(color: Colors.white, fontSize: 20.0))),
              Positioned(
                  right: 10.0,
                  top: 10.0,
                  child: Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(color: Color(0x80808080), blurRadius: 10, offset: Offset(0, 0))
                      ], borderRadius: BorderRadius.circular(50.0)),
                      child: ClipRRect(
                        child: Image.asset('assets/images/white_logo.png', fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(100.0),
                      )))
            ])));
  }
}
