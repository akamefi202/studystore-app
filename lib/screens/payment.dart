import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:currencies/currencies.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/components/rounded_button.dart';
import 'package:studystore_app/modules/string.dart';
import 'package:studystore_app/providers/messages.dart';
import 'package:studystore_app/providers/stores.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/screens/dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:studystore_app/models/product.dart';
import 'package:studystore_app/models/payment_type.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:fluwx/fluwx.dart' as fluwx;

class PaymentScreen extends StatefulWidget {
  static const routeName = 'screens/payment';

  PaymentScreen({Key key}) : super(key: key);
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  DateTime fromTime;
  DateTime toTime;
  Product product;
  PaymentType paymentType;
  final storage = FlutterSecureStorage();
  int storeId = -1;
  String token = '';
  int userId = -1;
  String userPhone = '';
  double currentBalance = 0.0;
  int freeHours = 0;
  double totalPrice = 0.0;
  double wechatAmount = 0.0; // amount of money which charged by wechat
  double balanceAmount = 0.0; // amount of money which charged by balance
  String tradeNo = '';
  bool paymentRequired = false;

  @override
  void initState() {
    super.initState();

    this.token = context.read<User>().token;
    this.userId = context.read<User>().id;
    this.userPhone = context.read<User>().phone;
    this.currentBalance = context.read<User>().currentBalance;
    this.freeHours = context.read<User>().freeHours;
    this.storeId = context.read<Stores>().storeId;

    fluwx.weChatResponseEventHandler.listen((res) async {
      if (res is fluwx.WeChatPaymentResponse) {
        print('wechat payment response: ' + res.isSuccessful.toString());
        if (res.isSuccessful && this.paymentRequired) {
          await this.createOrder();
          Navigator.of(context).pushNamed(DashboardScreen.routeName);
        }
        this.paymentRequired = false;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      Map<String, Object> arguments = ModalRoute.of(context).settings.arguments;
      fromTime = arguments['fromTime'];
      toTime = arguments['toTime'];
      product = arguments['product'];
      paymentType = arguments['paymentType'];
      totalPrice = arguments['totalPrice'];

      if (this.paymentType.type == 'hour') {
        if (this.getTimeAndBalanceStatus() == 1) {
          //Provider.of<User>(context, listen: false).updateCurrentBalance(0);
          balanceAmount = this.currentBalance;
          wechatAmount = this.totalPrice - this.currentBalance;
        } else {
          // 2
          balanceAmount = 0;
          wechatAmount = 0;
        }
      } else if (this.paymentType.type == 'day') {
        if (this.getTimeAndBalanceStatus() == 0 || this.getTimeAndBalanceStatus() == 1) {
          //Provider.of<User>(context, listen: false).updateCurrentBalance(0);
          balanceAmount = this.currentBalance;
          wechatAmount = this.totalPrice - this.currentBalance;
        } else {
          //Provider.of<User>(context, listen: false)
          //    .updateCurrentBalance(this.currentBalance - this.totalPrice);
          balanceAmount = this.totalPrice;
        }
      } else if (this.paymentType.type == 'month') {
        // month
        wechatAmount = this.totalPrice;
      } else if (this.paymentType.type == 'exp') {
        wechatAmount = this.totalPrice;
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

  // get status of 'free hours' field and 'balance' field
  int getTimeAndBalanceStatus() {
    if (this.paymentType == null) {
      return -1;
    }

    if (this.paymentType.type == 'hour') {
      if (this.freeHours == 0 && this.currentBalance == 0) {
        // can't select 'from time' field & 'to time' field
        // can't make order
        return 0;
      } else if (this.freeHours == 0 && this.currentBalance < this.paymentType.price) {
        // pay with balance and wechat
        return 1;
      } else {
        // this.freeHours > 0 || this.currentBalance >= this.selectedPaymentType.price
        // pay with free hours and balance later
        return 2;
      }
    } else if (this.paymentType.type == 'day') {
      if (this.currentBalance == 0) {
        // can't make order
        return 0;
      } else if (this.currentBalance < this.paymentType.price) {
        // pay with balance and wechat
        return 1;
      } else {
        // this.currentBalance >= this.selectedPaymentType.price
        // pay with only balance
        return 2;
      }
    } else if (this.paymentType.type == 'month') {
      // can make order
      // pay with wechat
      return 2;
    } else if (this.paymentType.type == 'exp') {
      if (this.currentBalance < this.paymentType.price) {
        // pay with balance and wechat
        return 1;
      } else {
        // this.currentBalance >= this.selectedPaymentType.price
        // pay with only balance
        return 2;
      }
    } else {
      return -1;
    }
  }

  Future<void> createOrder() async {
    print('createOrder');
    var url = Uri.parse(serverUrl + '/api/order/create');
    var body = jsonEncode({
      "user_id": this.userId,
      "user_phone": this.userPhone,
      "paytype_type": this.paymentType.type,
      "product_name": this.product.name,
      "product_id": this.product.id,
      "paytype_price": this.paymentType.price,
      "paytype_max_price": this.paymentType.maxPrice,
      "paytype_id": this.paymentType.id,
      "paytype_name": this.paymentType.name,
      "from_date": DateFormat("yyyy-MM-dd HH:mm:ss").format(this.fromTime),
      "to_date": DateFormat("yyyy-MM-dd HH:mm:ss").format(this.toTime),
      "total_price": this.wechatAmount == 0 ? 0 : this.totalPrice,
      "remain_money": this.balanceAmount,
      "payment_money": this.wechatAmount,
      "store_id": this.storeId,
      "pay_method": this.paymentType.type == 'month' ? 0 /* wechat */ : 1 /* balance */,
      "clienttype": 1,
      "remarks": "",
      "trade_no": this.tradeNo,
    });
    print(body);
    print(url);
    var response = await http.post(url,
        body: body, headers: {"Content-Type": "application/json", "x-access-token": this.token});
    print(response.body);

    // message badge test
    this.context.read<Messages>().updateNewMsgCount(this.context.read<Messages>().newMsgCount + 1);
  }

  /*Widget _showFromToTime() {
    if (this.paymentType.type == 'hour') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(getDateString(fromTime) + ' ' + getTimeString(fromTime)),
        ],
      );
    } else if (this.paymentType.type == 'day') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(getDateString(fromTime)),
        ],
      );
    } else {
      // month
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(getDateString(fromTime)),
          Container(
            width: 20.0,
          ),
          Icon(Icons.arrow_forward_outlined),
          Container(
            width: 20.0,
          ),
          Text(getDateString(toTime)),
        ],
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Scaffold(
      body: /*SingleChildScrollView(
          child:*/
          Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(lang.orderInform[lang.langMode], style: TextStyle(fontSize: 20.0)),
                      /*Container(height: 20.0),
                      Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0x80808080),
                                  blurRadius: 5,
                                  offset: Offset(0, 0))
                            ],
                          ),
                          width: data.size.width * 0.5,
                          child: Image.asset('assets/images/qrcode_ios.png')),*/
                      Container(height: 20.0),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(lang.date[lang.langMode] + ': ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(getStringFromDate(this.fromTime) +
                                ' ~ ' +
                                getStringFromDate(this.toTime))
                          ]),
                          Container(height: 10.0),
                          Row(children: [
                            Text(lang.time[lang.langMode] + ': ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(getStringFromTime(this.fromTime) +
                                ' ~ ' +
                                getStringFromTime(this.toTime))
                          ]),
                          Container(height: 10.0),
                          Row(children: [
                            Text(lang.seat[lang.langMode] + ': ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(product.name)
                          ]),
                          Container(height: 10.0),
                          Row(children: [
                            Text(lang.totalPrice[lang.langMode] + ': ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(currencies[Iso4217Code.jpy].symbol +
                                this.totalPrice.toStringAsFixed(2))
                          ]),
                          Container(height: 10.0),
                          Row(children: [
                            Text(lang.freeTime[lang.langMode] + ': ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(this.freeHours.toString() + lang.hour[lang.langMode])
                          ]),
                          Container(height: 10.0),
                          Row(children: [
                            Text(lang.currentBalance[lang.langMode] + ': ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(currencies[Iso4217Code.jpy].symbol +
                                this.currentBalance.toStringAsFixed(2))
                          ]),
                        ]))
                      ]),
                      Container(height: 40.0),
                      Text(lang.paymentMethod[lang.langMode], style: TextStyle(fontSize: 20.0)),
                      Container(height: 20.0),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Column(children: [
                          Container(
                              height: 50.0,
                              child: Center(child: Image.asset('assets/images/wechat.png'))),
                          Container(
                              height: 50.0,
                              child: Center(child: Image.asset('assets/images/recharge.png')))
                        ]),
                        Container(width: 20.0),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                              height: 50.0,
                              child: Center(child: Text(lang.wechatPay[lang.langMode]))),
                          Container(
                              height: 50.0,
                              child: Center(
                                  child: Text(lang.change[lang.langMode] +
                                      '(' +
                                      lang.balance[lang.langMode] +
                                      ')')))
                        ]),
                        Container(width: 20.0),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                              height: 50.0,
                              child: Center(
                                  child: Text(currencies[Iso4217Code.jpy].symbol +
                                      this.wechatAmount.toStringAsFixed(2)))),
                          Container(
                              height: 50.0,
                              child: Center(
                                  child: Text(currencies[Iso4217Code.jpy].symbol +
                                      this.balanceAmount.toStringAsFixed(2))))
                        ]),
                      ])
                    ],
                  ),
                  RoundedButton(
                    onPressed: () async {
                      if (this.wechatAmount > 0) {
                        // request wechat payment
                        var url = Uri.parse(serverUrl + '/api/wechat/pay_request');
                        var body = jsonEncode({
                          "money": this.wechatAmount,
                          "phone": context.read<User>().phone,
                          "trade_type": 0
                        });

                        var response = await http.post(url, body: body, headers: {
                          "Content-Type": "application/json",
                          "x-access-token": context.read<User>().token
                        });
                        var responseBody = jsonDecode(response.body);
                        Map<String, Object> result = responseBody['msg'];

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
                      } else {
                        // doesn't require wechat payment;
                        await this.createOrder();
                        Navigator.of(context).pushNamed(DashboardScreen.routeName);
                      }
                    },
                    title: lang.reservation[lang.langMode],
                    type: 0,
                  )
                ],
              )) /*)*/,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }
}
