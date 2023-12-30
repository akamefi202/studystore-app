import 'dart:convert';

import 'package:currencies/currencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/components/announcement_view.dart';
import 'package:studystore_app/components/order_view.dart';
import 'package:studystore_app/models/payment_type.dart';
import 'package:studystore_app/models/product.dart';
import 'package:studystore_app/modules/string.dart' as stringModule;
import 'package:studystore_app/models/order.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/constants/colors.dart';
import 'package:studystore_app/components/rounded_button.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/modules/string.dart';
import 'package:studystore_app/providers/messages.dart';
import 'package:studystore_app/providers/products.dart';
import 'package:studystore_app/providers/stores.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/screens/product_selection.dart';

class OrderCard extends StatefulWidget {
  final Order cardData;
  final PaymentType paymentType;

  OrderCard({Key key, this.cardData, this.paymentType}) : super(key: key);
  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  String token = '';
  String phone = '';
  String reason = '';
  int storeId = -1;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    this.token = context.read<User>().token;
    this.phone = context.read<User>().phone;
    this.storeId = context.read<Stores>().storeId;
  }

  Future<void> showCancelDialog() async {
    final data = MediaQuery.of(context);

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(lang.finish[lang.langMode]),
            content: Text(lang.askIfCancelOrder[lang.langMode]),
            actions: [
              ButtonBar(alignment: MainAxisAlignment.end, children: [
                RoundedButton(
                    title: lang.cancel1[lang.langMode],
                    type: 2,
                    onPressed: () async {
                      Navigator.pop(context);
                    }),
                Container(width: 10.0),
                RoundedButton(
                    title: lang.confirm[lang.langMode],
                    type: 2,
                    onPressed: () async {
                      Navigator.pop(context);

                      var url = Uri.parse(serverUrl + '/api/order/close');
                      var body = jsonEncode({"id": widget.cardData.id});

                      var response = await http.post(url, body: body, headers: {
                        "Content-Type": "application/json",
                        "x-access-token": this.token
                      });
                      print(response.body);

                      setState(() {
                        widget.cardData.toTime = DateTime.now();
                      });

                      // message badge test
                      this
                          .context
                          .read<Messages>()
                          .updateNewMsgCount(this.context.read<Messages>().newMsgCount + 1);
                    })
              ])
            ],
          );
        });
  }

  Future<void> showOpenCardDialog() async {
    final data = MediaQuery.of(context);

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(lang.openCard[lang.langMode]),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(lang.monthlyOrderWill[lang.langMode] +
                  stringModule.getStringFromDate(DateTime.now()) +
                  lang.restoreUse[lang.langMode] +
                  lang.dot[lang.langMode]),
              Container(height: 10.0),
              Text(lang.plzCheckCardOpenRules[lang.langMode]),
              Container(height: 10.0),
              Text(lang.askIfOpenCard[lang.langMode])
            ]),
            actions: [
              ButtonBar(alignment: MainAxisAlignment.end, children: [
                RoundedButton(
                    title: lang.cancel1[lang.langMode],
                    type: 2,
                    onPressed: () async {
                      Navigator.pop(context);
                    }),
                Container(width: 10.0),
                RoundedButton(
                    title: lang.confirm[lang.langMode],
                    type: 2,
                    onPressed: () async {
                      Navigator.pop(context);

                      var url = Uri.parse(serverUrl + '/api/request/create');
                      var body = jsonEncode({
                        "order_id": widget.cardData.id,
                        "req_type": 1,
                        "user_phone": this.phone,
                        "product_name": widget.cardData.productName,
                        "reason": ""
                      });

                      var response = await http.post(url, body: body, headers: {
                        "Content-Type": "application/json",
                        "x-access-token": this.token
                      });
                      print(response.body);

                      setState(() {
                        widget.cardData.pause = 2;
                      });

                      // message badge test
                      this
                          .context
                          .read<Messages>()
                          .updateNewMsgCount(this.context.read<Messages>().newMsgCount + 1);
                    })
              ])
            ],
          );
        });
  }

  Future<void> showStopCardDialog() async {
    final data = MediaQuery.of(context);

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(lang.stopCard[lang.langMode]),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(lang.monthlyOrderWill[lang.langMode] +
                  stringModule.getStringFromDate(DateTime.now()) +
                  lang.stopCard[lang.langMode] +
                  lang.dot[lang.langMode]),
              Container(height: 10.0),
              Text(lang.plzCheckCardStopRules[lang.langMode]),
              Container(height: 10.0),
              Text(lang.askIfStopCard[lang.langMode])
            ]),
            actions: [
              ButtonBar(alignment: MainAxisAlignment.end, children: [
                RoundedButton(
                    title: lang.cancel1[lang.langMode],
                    type: 2,
                    onPressed: () async {
                      Navigator.pop(context);
                    }),
                Container(width: 10.0),
                RoundedButton(
                    title: lang.confirm[lang.langMode],
                    type: 2,
                    onPressed: () async {
                      Navigator.pop(context);

                      var url = Uri.parse(serverUrl + '/api/request/create');
                      var body = jsonEncode({
                        "order_id": widget.cardData.id,
                        "req_type": 0,
                        "user_phone": this.phone,
                        "product_name": widget.cardData.productName,
                        "reason": ""
                      });

                      var response = await http.post(url, body: body, headers: {
                        "Content-Type": "application/json",
                        "x-access-token": this.token
                      });
                      print(response.body);

                      setState(() {
                        widget.cardData.pause = 1;
                      });

                      // message badge test
                      this
                          .context
                          .read<Messages>()
                          .updateNewMsgCount(this.context.read<Messages>().newMsgCount + 1);
                    })
              ])
            ],
          );
        });
  }

  void updateProductSwitch(int orderId, bool switchOn) async {
    var url = Uri.parse(serverUrl + '/api/lamp/onoff_orderid');
    var body = jsonEncode({"order_id": orderId, "onoff": switchOn});
    print(body);

    var response = await http.post(url,
        body: body, headers: {"Content-Type": "application/json", "x-access-token": this.token});

    setState(() {
      widget.cardData.switchOn = switchOn;
    });

    // message badge test
    this.context.read<Messages>().updateNewMsgCount(this.context.read<Messages>().newMsgCount + 1);
  }

  Future<void> changeProduct(Product product) async {
    var url = Uri.parse(serverUrl + '/api/order/exchange');
    var body = jsonEncode({
      "id": widget.cardData.id,
      "user_phone": this.phone,
      "old_product_id": widget.cardData.productId,
      "old_product_name": widget.cardData.productName,
      "new_product_id": product.id,
      "new_product_name": product.name,
      "store_id": this.storeId
    });

    print(body);
    var response = await http.post(url,
        body: body, headers: {"Content-Type": "application/json", "x-access-token": this.token});
    print(response.body);

    setState(() {
      widget.cardData.productId = product.id;
      widget.cardData.productName = product.name;
    });

    // message badge test
    this.context.read<Messages>().updateNewMsgCount(this.context.read<Messages>().newMsgCount + 1);
  }

  Widget renderTitle() {
    return Text(widget.cardData.paymentTypeName,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget renderCancelButton() {
    return RoundedButton(
      onPressed: () async {
        this.showCancelDialog();
      },
      type: 2,
      title: lang.finish[lang.langMode],
    );
  }

  Widget renderStopCardButton() {
    return RoundedButton(
      disabled: widget.cardData.pause == 2 ||
          widget.cardData.pause == 1 ||
          stringModule.getStringFromDate(widget.cardData.toTime) ==
              stringModule.getStringFromDate(DateTime.now()),
      onPressed: () async {
        this.showStopCardDialog();
      },
      type: 2,
      title: lang.stopCard[lang.langMode],
    );
  }

  Widget renderOpenCardButton() {
    return RoundedButton(
      disabled: widget.cardData.pause == 0 ||
          widget.cardData.pause == 2 ||
          stringModule.getStringFromDate(widget.cardData.toTime) ==
              stringModule.getStringFromDate(DateTime.now()),
      onPressed: () {
        this.showOpenCardDialog();
      },
      type: 2,
      title: lang.openCard[lang.langMode],
    );
  }

  Widget renderChangeSeatButton() {
    return RoundedButton(
      title: lang.changeSeat[lang.langMode],
      type: 2,
      onPressed: () {
        print('changeSeat');
        Navigator.of(context).pushNamed(ProductSelectionScreen.routeName, arguments: {
          'paymentType': widget.paymentType,
          'fromDateTime': DateTime.now(),
          'toDateTime': widget.cardData.toTime,
          'roomType': widget.paymentType.roomType
        }).then((value) {
          this.changeProduct(value);
        });
      },
    );
  }

  Widget renderSwitch() {
    return Switch(
        value: widget.cardData.switchOn,
        onChanged: (value) {
          this.updateProductSwitch(widget.cardData.id, value);
        });
  }

  Widget renderButtonGroup() {
    if (widget.paymentType.type == 'hour' ||
        widget.paymentType.type == 'day' ||
        widget.paymentType.type == 'exp') {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          this.renderCancelButton(),
          Container(width: 20),
          this.renderChangeSeatButton()
        ]),
        this.renderSwitch()
      ]);
    } else if (widget.paymentType.type == 'month') {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          this.renderStopCardButton(),
          Container(width: 20),
          this.renderOpenCardButton(),
          Container(width: 20),
          this.renderChangeSeatButton()
        ]),
        this.renderSwitch()
      ]);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(widget.cardData.fromTime.year, widget.cardData.fromTime.month,
        widget.cardData.fromTime.day, 0, 0, 0);
    DateTime endTime = widget.cardData.toTime;

    if (startTime.isBefore(now) && endTime.isAfter(now)) {
      // order is in progress now
      return Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              boxShadow: [
                BoxShadow(color: Color(0x80808080), blurRadius: 10, offset: Offset(0, 0))
              ],
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white),
          child: Column(
            children: [
              Row(children: [
                this.renderTitle(),
                Container(width: 20.0),
                Expanded(
                    flex: 6,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(lang.date[lang.langMode] +
                          ': ' +
                          stringModule.getStringFromDate(widget.cardData.fromTime) +
                          ' ~ ' +
                          stringModule.getStringFromDate(widget.cardData.toTime)),
                      Container(height: 10.0),
                      Text(lang.time[lang.langMode] +
                          ': ' +
                          stringModule.getStringFromTime(widget.cardData.fromTime) +
                          ' ~ ' +
                          stringModule.getStringFromTime(widget.cardData.toTime)),
                      Container(height: 10.0),
                      Text(lang.seat[lang.langMode] + ': ' + widget.cardData.productName),
                      Container(height: 10.0),
                      Text(lang.price[lang.langMode] +
                          ': ' +
                          currencies[Iso4217Code.jpy].symbol +
                          widget.cardData.price.toStringAsFixed(2)),
                    ]))
              ]),
              Container(height: 20.0),
              this.renderButtonGroup()
            ],
          ));
    } else {
      return Column(children: [
        Container(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                SvgPicture.asset('assets/icons/location.svg'),
                Container(width: 10.0),
                Column(children: [
                  Text(lang.yanjiWandaStore[lang.langMode], style: TextStyle(fontSize: 16.0)),
                  Container(height: 5.0),
                  Text(getStringFromDate(widget.cardData.fromTime),
                      style: TextStyle(fontSize: 16.0))
                ])
              ]),
              Row(children: [
                Text(currencies[Iso4217Code.jpy].symbol + widget.cardData.price.toString(),
                    style: TextStyle(fontSize: 20.0)),
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return OrderView(viewData: widget.cardData);
                          });
                    },
                    icon: Icon(Icons.arrow_forward_ios_outlined, size: 16.0, color: Colors.grey))
              ])
            ])),
        Container(height: 1, color: Color(0xffc0c0c0))
      ]);
    }
  }
}
