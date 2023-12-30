import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/components/rounded_button.dart';
import 'package:studystore_app/models/payment_type.dart';
import 'package:studystore_app/models/product.dart';
import 'package:studystore_app/modules/string.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/providers/products.dart';
import 'package:studystore_app/providers/stores.dart';
import 'package:studystore_app/providers/user.dart';

class ProductSelectionScreen extends StatefulWidget {
  static const routeName = 'screens/product_selection';

  ProductSelectionScreen({Key key}) : super(key: key);
  @override
  _ProductSelectionScreenState createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  List<Product> seatList = [];
  List<Product> meetingRoomList = [];
  Product selectedProduct = Product();
  PaymentType paymentType;
  int roomType;
  DateTime fromTime;
  DateTime toTime;
  String token = '';
  int storeId = -1;

  @override
  void initState() {
    super.initState();

    this.getData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      Map<String, Object> arguments = ModalRoute.of(context).settings.arguments;
      paymentType = arguments['paymentType'];
      roomType = arguments['roomType'];
      fromTime = arguments['fromDateTime'];
      toTime = arguments['toDateTime'];
      print('roomType: ' + roomType.toString());
    });
  }

  void getData() async {
    setState(() {
      this.token = context.read<User>().token;
      this.storeId = context.read<Stores>().storeId;
    });

    // get products from server
    await context.read<Products>().getProducts(this.storeId);

    context.read<Products>().findAvailableProducts(this.paymentType);
    await context.read<Products>().findOrderedProducts(this.storeId, this.fromTime, this.toTime);

    // get list of seats and meeting rooms
    setState(() {
      this.seatList = context.read<Products>().seatList;
      this.meetingRoomList = context.read<Products>().meetingRoomList;
    });
  }

  Widget showTabView(int floorNumber, double floorWidth) {
    String floorImage = '';
    List<Product> floorProductList = [];

    if (floorNumber == 1) {
      floorImage = 'assets/images/first_floor1.png';
      floorProductList = this.meetingRoomList;
    } else if (floorNumber == 2) {
      floorImage = 'assets/images/second_floor1.png';
      if (this.seatList.length >= 6) {
        floorProductList = this.seatList.sublist(0, 6);
      }
    } else {
      floorImage = 'assets/images/third_floor1.png';
      if (this.seatList.length >= 69) {
        floorProductList = this.seatList.sublist(6, 69);
      }
    }

    return SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.only(top: 20),
            child: Stack(children: [
              Image.asset(floorImage, width: double.infinity, fit: BoxFit.cover),
              ...floorProductList.map((e) {
                double productWidth = floorWidth * e.width;
                double productHeight = floorWidth * e.height;

                return Positioned(
                    left: e.x * floorWidth - productWidth * 0.5,
                    top: e.y * floorWidth * e.ratio - productHeight * 0.5,
                    child: GestureDetector(
                        onTap: e.available == true && e.ordered == false
                            ? () {
                                setState(() {
                                  this.selectedProduct = e;
                                });
                              }
                            : null,
                        child: Container(
                            width: productWidth,
                            height: productHeight,
                            color: e.available == true && e.ordered == false
                                ? (e.name == this.selectedProduct.name
                                    ? Color(0xc0fea340)
                                    : Colors.transparent)
                                : Color(0xc0b3bac4)))
                    /*IconButton(
                        icon: Icon(Icons.ac_unit,
                            color: e.available == true && e.ordered == false
                                ? (e.name == this.selectedProduct.name
                                    ? Color(0xfffea340)
                                    : Colors.transparent)
                                : Color(0xffb3bac4)),
                        onPressed: e.available == true && e.ordered == false
                            ? () {
                                setState(() {
                                  this.selectedProduct = e;
                                });
                              }
                            : null)*/
                    );
              }).toList()
            ])));
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    double floorWidth = data.size.width - 40;

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(lang.selectSeat[lang.langMode]),
        ),
        body: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /*Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(getStringFromDate(this.fromTime) +
                        ' ' +
                        getStringFromTime(this.fromTime) +
                        ' ~ ' +
                        getStringFromDate(this.toTime) +
                        ' ' +
                        getStringFromTime(this.toTime))),*/
                Expanded(
                    child: DefaultTabController(
                        length: this.roomType == 0 ? 2 : 1,
                        child: Column(children: [
                          TabBar(
                            tabs: this.roomType == 0
                                ? [
                                    Tab(text: lang.deck[lang.langMode]),
                                    Tab(text: 'VIP'),
                                  ]
                                : [Tab(text: lang.meetingRoom[lang.langMode])],
                            labelColor: Color(0xffff5e3a),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Color(0xffff5e3a),
                          ),
                          Expanded(
                              child: TabBarView(
                                  children: this.roomType == 0
                                      ? [showTabView(3, floorWidth), showTabView(2, floorWidth)]
                                      : [showTabView(1, floorWidth)]))
                        ]))),
                Container(height: 20.0),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                        color: Color(0xfff7f8fa),
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  Container(width: 10.0),
                  Text(lang.optional[lang.langMode]),
                  Container(
                    width: 20.0,
                  ),
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                        color: Color(0xffb3bac4),
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  Container(width: 10.0),
                  Text(lang.notOptional[lang.langMode]),
                  Container(width: 20.0),
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                        color: Color(0xfffea340),
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  Container(width: 10.0),
                  Text(lang.selected[lang.langMode]),
                ]),
                Container(height: 20.0),
                RoundedButton(
                    title: lang.confirm[lang.langMode],
                    type: 0,
                    onPressed: () {
                      Navigator.pop(context, this.selectedProduct);
                    })
              ],
            )));
  }
}
