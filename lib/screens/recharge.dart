import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/components/custom_dropdown_button.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/components/rounded_button.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:http/http.dart' as http;

class RechargeScreen extends StatefulWidget {
  static const routeName = 'screens/recharge';

  RechargeScreen({Key key}) : super(key: key);
  @override
  _RechargeScreenState createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  int rechargeAmount = 300;
  String tradeNo = '';
  bool paymentRequired = false;
  String phone;

  @override
  void initState() {
    super.initState();

    context.read<User>().updateUser();
    this.phone = context.read<User>().phone;

    fluwx.weChatResponseEventHandler.listen((res) async {
      if (res is fluwx.WeChatPaymentResponse) {
        print('wechat payment response: ' + res.isSuccessful.toString());
        if (res.isSuccessful && this.paymentRequired) {
          this.createRecharge();
        }
        this.paymentRequired = false;
      }
    });
  }

  Future<void> _showErrorDialog(String title, String content) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(lang.ok[lang.langMode]))
            ],
          );
        });
  }

  Future<void> createRecharge() async {
    print('createRecharge');
    var url = Uri.parse(serverUrl + '/api/charge/create');
    var body = jsonEncode(
        {"user_phone": this.phone, "money": this.rechargeAmount, "trade_no": this.tradeNo});
    print(body.toString());

    var response = await http.post(url, body: body, headers: {
      "Content-Type": "application/json",
      "x-access-token": context.read<User>().token
    });
    var responseBody = jsonDecode(response.body);
    print(response.body);

    context.read<User>().updateUser();
  }

  Future<void> showRechargeDialog() async {
    final data = MediaQuery.of(context);

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(lang.rechargeNow[lang.langMode]),
            content: Container(
                height: 200.0,
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(height: 20.0),
                      Row(children: [
                        Text(lang.currentBalance[lang.langMode] + ': ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(context.watch<User>().currentBalance.toStringAsFixed(2) +
                            ' ' +
                            lang.rmb[lang.langMode])
                      ]),
                      Container(
                        height: 10.0,
                      ),
                      Row(children: [
                        Text(lang.freeTime[lang.langMode] + ': ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(context.watch<User>().freeHours.toString() +
                            ' ' +
                            lang.hour[lang.langMode])
                      ]),
                      Container(height: 30.0),
                      Text(lang.rechargeAmount[lang.langMode]),
                      ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 100.0),
                          child: StatefulBuilder(builder: (context, setState) {
                            return CustomDropdownButton(
                              value: this.rechargeAmount.toString(),
                              items: ['300', '600', '900', '1200', '1500'].map((e) {
                                return DropdownMenuItem(value: e, child: Text(e));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  this.rechargeAmount = int.parse(value);
                                });
                              },
                            );
                            /*return DropdownButton(
                                isExpanded: true,
                                value: this.rechargeAmount.toString(),
                                icon: Icon(Icons.keyboard_arrow_down_outlined),
                                onChanged: (value) {
                                  setState(() {
                                    this.rechargeAmount = int.parse(value);
                                  });
                                },
                                items: ['300', '600', '900', '1200', '1500'].map((e) {
                                  return DropdownMenuItem(value: e, child: Text(e));
                                }).toList());*/
                          }))
                    ]))
                  ]),
                ])),
            actions: [
              ButtonBar(alignment: MainAxisAlignment.end, children: [
                RoundedButton(
                    onPressed: () async {
                      print(this.rechargeAmount);

                      var url = Uri.parse(serverUrl + '/api/wechat/pay_request');
                      var body = jsonEncode({
                        "phone": context.read<User>().phone,
                        "money": this.rechargeAmount,
                        "trade_type": 1
                      });

                      var response = await http.post(url, body: body, headers: {
                        "Content-Type": "application/json",
                        "x-access-token": context.read<User>().token
                      });
                      var responseBody = jsonDecode(response.body);

                      Map<String, Object> result = responseBody['msg'];
                      this.tradeNo = responseBody['trade_no'];

                      if (result['return_code'] == 'SUCCESS') {
                        this.paymentRequired = true;
                        fluwx
                            .payWithWeChat(
                                appId: result['appid'],
                                partnerId: result['mch_id'],
                                prepayId: result['prepay_id'],
                                packageValue: 'Sign=WXPay',
                                nonceStr: result['nonce_str'],
                                timeStamp: result['timestamp'],
                                sign: result['app_sign'])
                            .then((data) {
                          print('wechat app opened: ' + data.toString());
                          if (data == false) {
                            this._showErrorDialog(lang.warning[lang.langMode],
                                lang.wechatNotInstalled[lang.langMode]);
                          }
                        });
                      } else {
                        print(result['return_msg']);
                      }

                      Navigator.pop(context);
                    },
                    title: lang.pay[lang.langMode])
              ])
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(lang.recharge[lang.langMode]),
        ),
        body: Container(
            child: Stack(children: [
          Column(children: [
            Container(
              padding: EdgeInsets.only(top: 50.0),
              width: data.size.width,
              height: data.size.height * 0.25,
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(lang.studystore[lang.langMode],
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white))),
              color: Color(0xffb0bcb2),
            ),
            Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Color(0x80808080), blurRadius: 10, offset: Offset(0, 0))
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0))),
                padding: EdgeInsets.only(top: 20 + data.size.height * 0.05, bottom: 20),
                child: SingleChildScrollView(
                    child: Column(children: [
                  /*Container(
                    height: 20.0,
                  ),
                  Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Color(0x80808080),
                              blurRadius: 5,
                              offset: Offset(0, 0))
                        ],
                      ),
                      height: data.size.width * 0.33,
                      child: Image.asset('assets/images/qrcode_ios.png')),*/
                  Container(
                    height: 20.0,
                  ),
                  // show current balance and free hours
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(lang.currentBalance[lang.langMode] + ': ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(context.watch<User>().currentBalance.toStringAsFixed(2) +
                            ' ' +
                            lang.rmb[lang.langMode])
                      ]),
                      Container(
                        height: 10.0,
                      ),
                      Row(children: [
                        Text(lang.freeTime[lang.langMode] + ': ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(context.watch<User>().freeHours.toString() +
                            ' ' +
                            lang.hour[lang.langMode])
                      ])
                    ]))
                  ]),
                  Container(
                    height: 10.0,
                  ),
                  TextButton(
                      onPressed: () {
                        this.showRechargeDialog();
                      },
                      child: Text(lang.rechargeNow[lang.langMode],
                          style: TextStyle(
                              color: Color(0xffb0bcb2), fontSize: 18, fontWeight: FontWeight.bold)))
                ])))
          ]),
          Positioned(
              left: data.size.width / 2 - data.size.height * 0.05,
              top: data.size.height * 0.25 - data.size.height * 0.05,
              child: Container(
                  height: data.size.height * 0.1,
                  width: data.size.height * 0.1,
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(100.0),
                  ))),
        ])));
  }
}
