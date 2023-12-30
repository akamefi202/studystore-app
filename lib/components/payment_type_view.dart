import 'package:currencies/currencies.dart';
import 'package:flutter/material.dart';
import 'package:studystore_app/components/payment_type_card.dart';
import 'package:studystore_app/components/rounded_button.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:studystore_app/models/payment_type.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/screens/order.dart';
import 'package:studystore_app/screens/sign_in.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/models/announcement.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

class PaymentTypeView extends StatefulWidget {
  final PaymentType viewData;

  PaymentTypeView({Key key, this.viewData}) : super(key: key);
  @override
  _PaymentViewState createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentTypeView> {
  @override
  void initState() {
    super.initState();
  }

  Widget showPaymentCard() {
    final data = MediaQuery.of(context);

    return Container(
        width: double.infinity,
        height: data.size.height * 0.2,
        decoration: BoxDecoration(
            image:
                DecorationImage(image: NetworkImage(widget.viewData.imageUrl), fit: BoxFit.cover),
            boxShadow: [BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(0, 0))],
            borderRadius: BorderRadius.circular(10.0)),
        child: Stack(children: [
          Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget.viewData.name, style: TextStyle(color: Colors.white, fontSize: 20.0)),
            Container(height: 20.0),
            Text(currencies[Iso4217Code.jpy].symbol + widget.viewData.price.toStringAsFixed(2),
                style: TextStyle(color: Colors.white, fontSize: 20.0))
          ])),
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
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
      color: Colors.white,
      child: Column(
        children: [
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
                        this.showPaymentCard(),
                        Container(height: 20.0),
                        Html(data: widget.viewData.remarks),
                        Container(height: 40.0),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          RoundedButton(
                              title: lang.buy[lang.langMode],
                              type: 1,
                              onPressed: () {
                                if (context.read<User>().token == '') {
                                  Navigator.of(context).pushNamed(SignInScreen.routeName);
                                  return;
                                }

                                Navigator.of(context).pushNamed(OrderScreen.routeName,
                                    arguments: {'paymentType': widget.viewData});
                              })
                        ])
                      ]))))
        ],
      ),
    ));
  }
}
