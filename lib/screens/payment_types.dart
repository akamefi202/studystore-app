import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/components/payment_type_card.dart';
import 'package:studystore_app/components/recharge_card.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/components/rounded_button.dart';
import 'package:studystore_app/models/payment_type.dart';
import 'package:studystore_app/providers/payment_types.dart';
import 'package:studystore_app/providers/stores.dart';
import 'package:studystore_app/providers/user.dart';

class PaymentTypesScreen extends StatefulWidget {
  static const routeName = 'screens/payment_types';

  PaymentTypesScreen({Key key}) : super(key: key);
  @override
  _PaymentTypesScreenState createState() => _PaymentTypesScreenState();
}

class _PaymentTypesScreenState extends State<PaymentTypesScreen> {
  List<PaymentType> paymentTypeList = [];
  String token = '';
  int storeId = -1;

  @override
  void initState() {
    super.initState();

    this.getData();
  }

  void getData() async {
    this.token = context.read<User>().token;
    this.storeId = context.read<Stores>().storeId;

    await context.read<PaymentTypes>().getPaymentTypes(this.storeId);
    await context.read<User>().updateUser();

    setState(() {
      this.paymentTypeList = context.read<PaymentTypes>().paymentTypeList;
      if (context.read<User>().usedExpCard == true) {
        this.paymentTypeList.removeWhere((element) => element.type == 'exp');
      }
    });
  }

  List<Widget> getItems() {
    List<Widget> items = [];
    items.add(Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
        child: RechargeCard()));

    this.paymentTypeList.forEach((element) {
      items.add(Container(
          margin: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
          child: PaymentTypeCard(cardData: element)));
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Scaffold(
        body: SingleChildScrollView(
            padding: EdgeInsets.only(top: 50.0, bottom: 10.0),
            child: Column(children: this.getItems())));
  }
}
