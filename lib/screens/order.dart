import 'dart:convert';
import 'package:currencies/currencies.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/components/rounded_button.dart';
import 'package:studystore_app/providers/products.dart';
import 'package:studystore_app/providers/stores.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/providers/payment_types.dart';
import 'package:studystore_app/screens/product_selection.dart';
import 'package:studystore_app/screens/payment.dart';
import 'package:studystore_app/constants/colors.dart';
import 'package:studystore_app/modules/string.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:studystore_app/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/constants/config.dart';
import 'package:studystore_app/models/payment_type.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/constants/product_positions.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = 'screens/order';

  OrderScreen({Key key}) : super(key: key);
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<PaymentType> paymentTypeList = [];
  List<Product> seatList = [];
  List<Product> meetingRoomList = [];
  List<String> daySelectionList = [lang.today[lang.langMode], lang.tomorrow[lang.langMode]];
  String selectedDayStr = lang.today[lang.langMode]; // 'today' or 'tomorrow'
  List<int> hourSelectionList = [];
  int selectedHoursCount;
  bool hourPaymentUnlimited = false;
  PaymentType selectedPaymentType;
  Product selectedProduct;
  DateTime selectedDate = DateTime.now();
  DateTime fromTime;
  DateTime toTime;
  double totalPrice = 0.0;
  String token = '';
  String phone = '';
  int storeId = -1; // id of selected store
  //DateTime storeFromTime; // start time of selected store
  //DateTime storeToTime; // end time of selected store
  int freeHours = 0; // free hours of user
  double currentBalance = 0.0; // current balance of user
  int roomType; // 0: seat, 1: meeting room

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
      if (arguments['paymentType'] != null) {
        // set 'payment type' and 'room type' from 'payment cards' screen
        PaymentType pt = arguments['paymentType'];
        this.selectPaymentType(pt);
        this.roomType = pt.roomType;
      } else if (arguments['roomType'] != null) {
        // set 'room type' from home screen
        if (arguments['roomType'] == 0) {
          this.roomType = arguments['roomType'];
        } else {
          // 1
          this.roomType = arguments['roomType'];
        }
      }
    });
  }

  void getData() async {
    setState(() {
      // get token of user and 'store id' field of selected store
      this.token = context.read<User>().token;
      this.phone = context.read<User>().phone;
      this.storeId = context.read<Stores>().storeId;

      // get 'current balance' & 'free hours' fields of user
      this.currentBalance = context.read<User>().currentBalance;
      this.freeHours = context.read<User>().freeHours;

      // get 'store from time' & 'store to time' fields
      //this.storeFromTime = context.read<Stores>().storeList[0].fromTime;
      //this.storeToTime = context.read<Stores>().storeList[0].toTime;
    });

    // get payment types from server
    await context.read<PaymentTypes>().getPaymentTypes(this.storeId);
    await context.read<User>().updateUser();

    // select the payment type as first payment type as default
    setState(() {
      if (this.roomType == 0) {
        this.paymentTypeList = context.read<PaymentTypes>().getSeatPaymentTypes();
      } else {
        this.paymentTypeList = context.read<PaymentTypes>().getMeetingRoomPaymentTypes();
      }

      // remove experience payment type if user used it already
      if (context.read<User>().usedExpCard == true) {
        this.paymentTypeList.removeWhere((element) => element.type == 'exp');
      }

      if (this.paymentTypeList.length > 0 && this.selectedPaymentType == null) {
        this.selectPaymentType(this.paymentTypeList[0]);
      }
    });

    // get products from server
    await context.read<Products>().getProducts(this.storeId);

    // get list of seats and meeting rooms
    setState(() {
      this.seatList = context.read<Products>().seatList;
      this.meetingRoomList = context.read<Products>().meetingRoomList;
    });
  }

  // select payment type
  void selectPaymentType(PaymentType paymentType) {
    setState(() {
      this.selectedPaymentType = paymentType;

      // change dates of 'from time' & 'to time' fields to today
      DateTime now = DateTime.now();
      this.selectedPaymentType.fromTime = DateTime(now.year, now.month, now.day,
          this.selectedPaymentType.fromTime.hour, this.selectedPaymentType.fromTime.minute);
      this.selectedPaymentType.toTime = DateTime(now.year, now.month, now.day,
          this.selectedPaymentType.toTime.hour, this.selectedPaymentType.toTime.minute);

      // set 'from time' & 'to time' fields
      if (this.selectedPaymentType.type == 'hour') {
        // set 'from time' field
        this.fromTime = now;
        // set 'from time' field between 'store from time' value and 'store to time' value
        if (this.fromTime.isAfter(this.selectedPaymentType.toTime)) {
          this.fromTime = this.selectedPaymentType.toTime;
        }
        if (this.fromTime.isBefore(this.selectedPaymentType.fromTime)) {
          this.fromTime = this.selectedPaymentType.fromTime;
        }

        // set available hours count selection list
        if (this.getTimeAndBalanceStatus() == 1) {
          // should select hours
          this.hourSelectionList = this.getHourSelectionList();
        } else {
          // 0 or 2
          this.hourSelectionList = [];
        }

        // set selected hours count as 1 as default
        if (this.hourSelectionList.length > 0) {
          this.selectedHoursCount = 1;
        } else {
          this.selectedHoursCount = 0;
        }

        // set to time
        if (this.hourSelectionList.length > 0) {
          this.toTime = DateTime(this.fromTime.year, this.fromTime.month, this.fromTime.day,
              this.fromTime.hour + 1, this.fromTime.minute);
          if (this.toTime.isAfter(this.selectedPaymentType.toTime)) {
            this.toTime = this.selectedPaymentType.toTime;
          }
        } else {
          this.toTime = this.selectedPaymentType.toTime;
        }

        // set total price
        if (this.hourSelectionList.length > 0) {
          this.totalPrice =
              this.selectedPaymentType.price * (this.toTime.hour - this.fromTime.hour);
          if (this.totalPrice >= this.selectedPaymentType.maxPrice) {
            this.totalPrice = this.selectedPaymentType.maxPrice;
          }
        } else {
          this.totalPrice = 0;
        }
      } else if (this.selectedPaymentType.type == 'day') {
        this.selectedDayStr = lang.today[lang.langMode];

        // set 'from time' field
        this.fromTime = now;
        // set 'from time' field between 'store from time' value and 'store to time' value
        if (this.fromTime.isAfter(this.selectedPaymentType.toTime)) {
          this.fromTime = this.selectedPaymentType.toTime;
        }
        if (this.fromTime.isBefore(this.selectedPaymentType.fromTime)) {
          this.fromTime = this.selectedPaymentType.fromTime;
        }

        this.toTime = DateTime(now.year, now.month, now.day, selectedPaymentType.toTime.hour,
            selectedPaymentType.toTime.minute);

        this.totalPrice = this.selectedPaymentType.price;
      } else if (this.selectedPaymentType.type == 'month') {
        // month
        this.fromTime = DateTime(now.year, now.month, now.day + 1,
            this.selectedPaymentType.fromTime.hour, this.selectedPaymentType.fromTime.minute);
        this.toTime = DateTime(now.year, now.month + 1, now.day,
            this.selectedPaymentType.toTime.hour, this.selectedPaymentType.toTime.minute);

        this.totalPrice = this.selectedPaymentType.price;
      } else {
        // exp
        // set 'from time' field
        this.fromTime = now;
        // set 'from time' field between 'store from time' value and 'store to time' value
        if (this.fromTime.isAfter(this.selectedPaymentType.toTime)) {
          this.fromTime = this.selectedPaymentType.toTime;
        }
        if (this.fromTime.isBefore(this.selectedPaymentType.fromTime)) {
          this.fromTime = this.selectedPaymentType.fromTime;
        }

        this.toTime = DateTime(this.fromTime.year, this.fromTime.month, this.fromTime.day,
            this.fromTime.hour + 3, this.fromTime.minute);
        if (this.toTime.isAfter(this.selectedPaymentType.toTime)) {
          this.toTime = this.selectedPaymentType.toTime;
        }

        this.totalPrice = this.selectedPaymentType.price;
      }
    });
  }

  // get hour selection list
  List<int> getHourSelectionList() {
    List<int> selectionList = [];
    int limit = this.selectedPaymentType.toTime.hour - this.fromTime.hour;
    if (limit < 0) {
      limit = 0;
    }

    for (int i = 1; i <= limit; i++) {
      selectionList.add(i);
    }

    return selectionList;
  }

  // get status of 'free hours' field and 'balance' field
  int getTimeAndBalanceStatus() {
    if (this.selectedPaymentType == null) {
      return -1;
    }

    if (this.selectedPaymentType.type == 'hour') {
      if (this.freeHours == 0 && this.currentBalance == 0) {
        // can't select 'from time' field & 'to time' field
        // can't make order
        return 0;
      } else if (this.freeHours == 0 && this.currentBalance < this.selectedPaymentType.price) {
        // pay with balance and wechat
        return 1;
      } else {
        // this.freeHours > 0 || this.currentBalance >= this.selectedPaymentType.price
        // pay with free hours and balance later
        return 2;
      }
    } else if (this.selectedPaymentType.type == 'day') {
      if (this.currentBalance == 0) {
        // can't make order
        return 0;
      } else if (this.currentBalance < this.selectedPaymentType.price) {
        // pay with balance and wechat
        return 1;
      } else {
        // this.currentBalance >= this.selectedPaymentType.price
        // pay with only balance
        return 2;
      }
    } else if (this.selectedPaymentType.type == 'month') {
      // can make order
      // pay with wechat
      return 2;
    } else if (this.selectedPaymentType.type == 'exp') {
      if (this.currentBalance < this.selectedPaymentType.price) {
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

  Future<void> _showTimeSelectionDialog(String title, String content) async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: foreColor, borderRadius: BorderRadius.circular(10.0)),
                      child: TimePickerSpinner(
                        time: this.fromTime,
                        isForce2Digits: true,
                        is24HourMode: false,
                        normalTextStyle:
                            TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 30.0),
                        highlightedTextStyle: TextStyle(color: Colors.white, fontSize: 30.0),
                        onTimeChange: (value) {
                          this.fromTime = value;
                        },
                      )),
                  Container(height: 20.0),
                  Container(
                      width: double.infinity,
                      height: 50.0,
                      child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);

                            DateTime time = this.fromTime;
                            if (time == null) {
                              return;
                            }

                            setState(() {
                              if (this.selectedPaymentType.type == 'hour') {
                                this.fromTime = time;
                                if (this.fromTime.isBefore(DateTime.now())) {
                                  this.fromTime = DateTime.now();
                                }
                                if (this.fromTime.isBefore(this.selectedPaymentType.fromTime)) {
                                  this.fromTime = this.selectedPaymentType.fromTime;
                                }
                                if (this.fromTime.isAfter(this.selectedPaymentType.toTime)) {
                                  this.fromTime = this.selectedPaymentType.toTime;
                                }

                                if (this.getTimeAndBalanceStatus() == 1) {
                                  this.hourSelectionList = this.getHourSelectionList();
                                } else {
                                  this.hourSelectionList = [];
                                }

                                if (this.hourSelectionList.length > 0) {
                                  this.selectedHoursCount = 1;
                                } else {
                                  this.selectedHoursCount = 0;
                                }

                                if (this.hourSelectionList.length > 0) {
                                  this.toTime = DateTime(
                                      this.fromTime.year,
                                      this.fromTime.month,
                                      this.fromTime.day,
                                      this.fromTime.hour + 1,
                                      this.fromTime.minute);
                                  if (this.toTime.isAfter(this.selectedPaymentType.toTime)) {
                                    this.toTime = this.selectedPaymentType.toTime;
                                  }
                                } else {
                                  this.toTime = this.selectedPaymentType.toTime;
                                }

                                if (this.hourSelectionList.length > 0) {
                                  this.totalPrice = this.selectedPaymentType.price *
                                      (this.toTime.hour - this.fromTime.hour);
                                  if (this.totalPrice >= this.selectedPaymentType.maxPrice) {
                                    this.totalPrice = this.selectedPaymentType.maxPrice;
                                  }
                                } else {
                                  this.totalPrice = 0;
                                }
                              } else if (this.selectedPaymentType.type == 'exp') {
                                this.fromTime = time;
                                if (this.fromTime.isBefore(DateTime.now())) {
                                  this.fromTime = DateTime.now();
                                }
                                if (this.fromTime.isBefore(this.selectedPaymentType.fromTime)) {
                                  this.fromTime = this.selectedPaymentType.fromTime;
                                }
                                if (this.fromTime.isAfter(this.selectedPaymentType.toTime)) {
                                  this.fromTime = this.selectedPaymentType.toTime;
                                }

                                this.toTime = DateTime(
                                    this.fromTime.year,
                                    this.fromTime.month,
                                    this.fromTime.day,
                                    this.fromTime.hour + 3,
                                    this.fromTime.minute);
                                if (this.toTime.isAfter(this.selectedPaymentType.toTime)) {
                                  this.toTime = this.selectedPaymentType.toTime;
                                }

                                // price of experience payment type is total price or hourly rate?
                                this.totalPrice = this.selectedPaymentType.price;
                              }
                            });
                          },
                          child: Text(
                            lang.confirm[lang.langMode],
                            style: TextStyle(color: foreColor),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color(0xfff2f2f2)),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0))))))
                ],
              ));
        });
  }

  Future<void> _showDateSelectionDialog(String title, String content) async {
    showModalBottomSheet(
        //showCupertinoDialog(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
              color: Colors.white,
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SfDateRangePicker(
                      allowViewNavigation: false,
                      selectionMode: DateRangePickerSelectionMode.single,
                      initialSelectedDate: this.selectedDate,
                      initialDisplayDate: this.selectedDate,
                      onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                        this.selectedDate = args.value;
                      }),
                  //Container(height: 20.0),
                  Container(
                      width: double.infinity,
                      height: 50.0,
                      child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);

                            DateTime date = this.selectedDate;
                            if (date == null) {
                              return;
                            }

                            setState(() {
                              DateTime now = DateTime.now();
                              DateTime tomorrow = DateTime(
                                  now.year,
                                  now.month,
                                  now.day + 1,
                                  this.selectedPaymentType.fromTime.hour,
                                  this.selectedPaymentType.fromTime.minute);

                              this.fromTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  this.selectedPaymentType.fromTime.hour,
                                  this.selectedPaymentType.fromTime.minute);
                              if (this.fromTime.isBefore(tomorrow)) {
                                this.fromTime = tomorrow;
                              }

                              this.toTime = DateTime(
                                  this.fromTime.year,
                                  this.fromTime.month + 1,
                                  this.fromTime.day - 1,
                                  selectedPaymentType.toTime.hour,
                                  selectedPaymentType.toTime.minute);
                            });
                          },
                          child: Text(
                            lang.confirm[lang.langMode],
                            style: TextStyle(color: foreColor),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color(0xfff2f2f2)),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0))))))
                ],
              ));
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

  List<Widget> _showDateTimePicker() {
    final data = MediaQuery.of(context);

    if (this.selectedPaymentType == null) {
      return [];
    } else if (this.selectedPaymentType.type == 'hour') {
      return [
        Container(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(width: 1, color: Color(0xffe9e9e9))),
            child: Row(children: [
              GestureDetector(
                  onTap: () {
                    if (this.getTimeAndBalanceStatus() == 0) {
                      return;
                    }

                    this._showTimeSelectionDialog(lang.selectTime[lang.langMode], '');
                  },
                  child: Container(
                      width: data.size.width * 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.orderTime[lang.langMode],
                            style: TextStyle(color: foreColor),
                          ),
                          Container(
                            height: 10.0,
                          ),
                          Container(
                              child: Text(getStringFromTime(this.fromTime),
                                  style: TextStyle(
                                      color: this.getTimeAndBalanceStatus() == 0
                                          ? Colors.grey
                                          : Colors.black))),
                        ],
                      ))),
              Container(
                  width: data.size.width * 0.25,
                  child: DropdownButton(
                      menuMaxHeight: data.size.height * 0.5,
                      isExpanded: true,
                      value: this.selectedHoursCount,
                      icon: Icon(Icons.keyboard_arrow_down_outlined),
                      onChanged: this.hourSelectionList.length > 0
                          ? (value) {
                              setState(() {
                                this.selectedHoursCount = value;
                                this.toTime = DateTime(
                                    this.fromTime.year,
                                    this.fromTime.month,
                                    this.fromTime.day,
                                    this.fromTime.hour + value,
                                    this.fromTime.minute);
                                if (this.toTime.isAfter(this.selectedPaymentType.toTime)) {
                                  this.toTime = this.selectedPaymentType.toTime;
                                }

                                this.totalPrice = this.selectedPaymentType.price *
                                    (this.toTime.hour - this.fromTime.hour);
                                if (this.totalPrice >= this.selectedPaymentType.maxPrice) {
                                  this.totalPrice = this.selectedPaymentType.maxPrice;
                                }
                              });
                            }
                          : null,
                      items: this.hourSelectionList.length > 0
                          ? this.hourSelectionList.map((e) {
                              return DropdownMenuItem(
                                  value: e, child: Text(e.toString() + lang.hour[lang.langMode]));
                            }).toList()
                          : [
                              DropdownMenuItem(value: 0, child: Text(lang.unlimited[lang.langMode]))
                            ]))
            ]))
      ];
    } else if (this.selectedPaymentType.type == 'day') {
      return [
        Text(
          lang.orderDate[lang.langMode],
          style: TextStyle(color: Colors.grey),
        ),
        Container(
            width: double.infinity,
            child: DropdownButton(
                isExpanded: true,
                value: this.selectedDayStr,
                icon: Icon(Icons.keyboard_arrow_down_outlined),
                onChanged: (value) {
                  setState(() {
                    DateTime now = DateTime.now();
                    if (value == lang.today[lang.langMode]) {
                      this.selectedDayStr = lang.today[lang.langMode];

                      this.fromTime = now;
                      if (this.fromTime.isBefore(this.selectedPaymentType.fromTime)) {
                        this.fromTime = this.selectedPaymentType.fromTime;
                      }
                      if (this.fromTime.isAfter(this.selectedPaymentType.toTime)) {
                        this.fromTime = this.selectedPaymentType.toTime;
                      }

                      this.toTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          this.selectedPaymentType.toTime.hour,
                          this.selectedPaymentType.toTime.minute);
                      if (this.toTime.isAfter(this.selectedPaymentType.toTime)) {
                        this.toTime = this.selectedPaymentType.toTime;
                      }
                    } else {
                      this.selectedDayStr = lang.tomorrow[lang.langMode];
                      this.fromTime = DateTime(
                          now.year,
                          now.month,
                          now.day + 1,
                          this.selectedPaymentType.fromTime.hour,
                          this.selectedPaymentType.fromTime.minute);
                      this.toTime = DateTime(
                          now.year,
                          now.month,
                          now.day + 1,
                          this.selectedPaymentType.toTime.hour,
                          this.selectedPaymentType.toTime.minute);
                    }
                  });
                },
                items: this.daySelectionList.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList()))
      ];
    } else if (this.selectedPaymentType.type == 'month') {
      return [
        GestureDetector(
            child: Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(width: 1, color: Color(0xffe9e9e9))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.orderDate[lang.langMode],
                    style: TextStyle(color: foreColor),
                  ),
                  Container(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(getStringFromDate(this.fromTime)),
                      Icon(Icons.arrow_forward_outlined),
                      Text(getStringFromDate(this.toTime)),
                    ],
                  )
                ],
              ),
            ),
            onTap: () {
              this.selectedDate = this.fromTime;
              this._showDateSelectionDialog(lang.selectDate[lang.langMode], '');
            })
      ];
    } else {
      // if type of selected payment type is 'exp'
      return [
        Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(width: 1, color: Color(0xffe9e9e9))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.orderTime[lang.langMode],
                style: TextStyle(color: foreColor),
              ),
              Container(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        this._showTimeSelectionDialog(lang.selectTime[lang.langMode], '');
                      },
                      child: Container(
                          child: Text(getStringFromTime(this.fromTime),
                              style: TextStyle(color: Colors.black)))),
                  Icon(Icons.arrow_forward_outlined),
                  Container(
                      child: Text(getStringFromTime(toTime), style: TextStyle(color: Colors.grey)))
                ],
              )
            ],
          ),
        )
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // payment type combo box
                Text(
                  lang.paymentType[lang.langMode],
                  style: TextStyle(color: Colors.grey),
                ),
                Container(
                    width: double.infinity,
                    child: DropdownButton(
                        isExpanded: true,
                        value:
                            this.selectedPaymentType != null ? this.selectedPaymentType.name : null,
                        icon: Icon(Icons.keyboard_arrow_down_outlined),
                        onChanged: (value) {
                          setState(() {
                            this.selectedDayStr = lang.today[lang.langMode];
                            this.selectedProduct = null;
                            this.selectPaymentType(this
                                .paymentTypeList
                                .firstWhere((element) => element.name == value));
                          });
                        },
                        items: paymentTypeList.map((e) {
                          return DropdownMenuItem(value: e.name, child: Text(e.name));
                        }).toList())),
                Container(
                  height: 20.0,
                ),
                ...this._showDateTimePicker(),
                Container(
                  height: 20.0,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  RoundedButton(
                      onPressed: () {
                        if (this.selectedPaymentType == null) {
                          this._showErrorDialog(lang.warning[lang.langMode],
                              lang.plzSelectPaymentType[lang.langMode]);
                          return;
                        }

                        Navigator.of(context)
                            .pushNamed(ProductSelectionScreen.routeName, arguments: {
                          'paymentType': this.selectedPaymentType,
                          'roomType': this.roomType,
                          'fromDateTime': this.fromTime,
                          'toDateTime': this.toTime
                        }).then((value) {
                          setState(() {
                            this.selectedProduct = value;
                          });
                        });
                      },
                      title: lang.seatSelection[lang.langMode],
                      type: 0)
                ]),
                Container(
                  height: 40.0,
                ),
                // selected payment type
                if (this.selectedPaymentType != null)
                  Container(
                      margin: EdgeInsets.only(bottom: 20, left: 10),
                      child: Row(children: [
                        Text(lang.paymentTypePrice[lang.langMode] + ': ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(currencies[Iso4217Code.jpy].symbol +
                            this.selectedPaymentType.price.toStringAsFixed(2))
                      ])),
                // total price
                Container(
                    margin: EdgeInsets.only(bottom: 20, left: 10),
                    child: Row(children: [
                      Text(lang.totalPrice[lang.langMode] + ': ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(currencies[Iso4217Code.jpy].symbol + this.totalPrice.toStringAsFixed(2))
                    ])),
                // from time
                if (this.selectedPaymentType != null && this.fromTime != null)
                  Container(
                      margin: EdgeInsets.only(bottom: 20, left: 10),
                      child: Row(children: [
                        Text(lang.fromTime[lang.langMode] + ': ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(getStringFromDate(this.fromTime) +
                            ' ' +
                            getStringFromTime(this.fromTime))
                      ])),
                // to time
                if (this.selectedPaymentType != null && this.toTime != null)
                  Container(
                      margin: EdgeInsets.only(bottom: 20, left: 10),
                      child: Row(children: [
                        Text(lang.toTime[lang.langMode] + ': ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(getStringFromDate(this.toTime) + ' ' + getStringFromTime(this.toTime))
                      ])),
                // selected product
                if (this.selectedProduct != null)
                  Container(
                      margin: EdgeInsets.only(bottom: 20, left: 10),
                      child: Row(children: [
                        Text(lang.seat[lang.langMode] + ': ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(this.selectedProduct.name)
                      ])),
                Container(
                    margin: EdgeInsets.only(bottom: 20, left: 10),
                    child: Row(children: [
                      Text(lang.freeTime[lang.langMode] + ': ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(this.freeHours.toString() + lang.hour[lang.langMode])
                    ])),
                Container(
                    margin: EdgeInsets.only(bottom: 20, left: 10),
                    child: Row(children: [
                      Text(lang.currentBalance[lang.langMode] + ': ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(currencies[Iso4217Code.jpy].symbol +
                          this.currentBalance.toStringAsFixed(2))
                    ])),
              ]))),
              Container(height: 20.0),
              RoundedButton(
                  title: lang.reservation1[lang.langMode],
                  type: 0,
                  onPressed: () async {
                    if (this.selectedProduct == null) {
                      this._showErrorDialog(
                          lang.warning[lang.langMode], lang.plzSelectSeat[lang.langMode]);
                      return;
                    }

                    if (this.selectedPaymentType == null) {
                      this._showErrorDialog(
                          lang.warning[lang.langMode], lang.plzSelectPaymentType[lang.langMode]);
                      return;
                    }

                    if (this.selectedPaymentType.type == 'hour' &&
                        this.getTimeAndBalanceStatus() == 0) {
                      this._showErrorDialog(
                          lang.warning[lang.langMode], lang.emptyBalance[lang.langMode]);
                      return;
                    }

                    if (this.toTime.difference(this.fromTime).inMinutes < 15) {
                      this._showErrorDialog(
                          lang.warning[lang.langMode], lang.notEnoughTime[lang.langMode]);
                      return;
                    }

                    if (await context
                        .read<Products>()
                        .findCurrentOrder(this.phone, this.storeId, this.fromTime, this.toTime)) {
                      this._showErrorDialog(
                          lang.warning[lang.langMode], lang.notMoreThanOneOrder[lang.langMode]);
                      return;
                    }

                    //await this.updateProducts();
                    Product selectedProduct = this
                        .seatList
                        .firstWhere((element) => element.id == this.selectedProduct.id);

                    if (selectedProduct.ordered == true) {
                      this._showErrorDialog(
                          lang.warning[lang.langMode], lang.seatAlreadyOrdered[lang.langMode]);
                      return;
                    }

                    Navigator.of(context).pushNamed(PaymentScreen.routeName, arguments: {
                      'fromTime': this.fromTime,
                      'toTime': this.toTime,
                      'product': this.selectedProduct,
                      'paymentType': this.selectedPaymentType,
                      'totalPrice': this.totalPrice
                    });
                  })
            ],
          )),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(lang.order[lang.langMode]),
      ),
    );
  }
}
