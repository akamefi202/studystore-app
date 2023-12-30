import 'package:currencies/currencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/models/order.dart';
import 'package:studystore_app/modules/string.dart' as stringModule;

class OrderView extends StatefulWidget {
  final Order viewData;

  OrderView({Key key, this.viewData}) : super(key: key);
  @override
  _OrderViewState createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
            color: Colors.white,
            child: Column(children: [
              Row(children: [
                IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ], mainAxisAlignment: MainAxisAlignment.start),
              Container(
                height: 20.0,
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: Container(
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(lang.orderDetails[lang.langMode],
                                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                            Container(height: 30.0),
                            Row(
                              children: [
                                SvgPicture.asset('assets/icons/location.svg'),
                                Container(width: 10.0),
                                Text(lang.yanjiWandaStore[lang.langMode],
                                    style: TextStyle(fontSize: 18.0))
                              ],
                            ),
                            Container(height: 30.0),
                            Text(
                                lang.date[lang.langMode] +
                                    ': ' +
                                    stringModule.getStringFromDate(widget.viewData.fromTime) +
                                    ' ~ ' +
                                    stringModule.getStringFromDate(widget.viewData.toTime),
                                style: TextStyle(fontSize: 16.0)),
                            Container(height: 10.0),
                            Text(
                                lang.time[lang.langMode] +
                                    ': ' +
                                    stringModule.getStringFromTime(widget.viewData.fromTime) +
                                    ' ~ ' +
                                    stringModule.getStringFromTime(widget.viewData.toTime),
                                style: TextStyle(fontSize: 16.0)),
                            Container(height: 10.0),
                            Text(lang.type[lang.langMode] + ': ' + widget.viewData.paymentTypeName,
                                style: TextStyle(fontSize: 16.0)),
                            Container(height: 10.0),
                            Text(lang.seat[lang.langMode] + ': ' + widget.viewData.productName,
                                style: TextStyle(fontSize: 16.0)),
                            Container(height: 10.0),
                            Text(
                                lang.price[lang.langMode] +
                                    ': ' +
                                    currencies[Iso4217Code.jpy].symbol +
                                    widget.viewData.price.toStringAsFixed(2),
                                style: TextStyle(fontSize: 16.0)),
                          ]))))
            ])));
  }
}
