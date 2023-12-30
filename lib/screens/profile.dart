import 'dart:convert';
import 'package:currencies/currencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/components/order_view.dart';
import 'package:studystore_app/providers/orders.dart';
import 'package:studystore_app/providers/payment_types.dart';
import 'package:studystore_app/providers/stores.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/screens/settings.dart';
import 'package:studystore_app/models/order.dart';
import 'package:studystore_app/models/payment_type.dart';
import 'package:studystore_app/modules/string.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/constants/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studystore_app/components/order_card.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/screens/sign_in.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = 'screens/profile';

  ProfileScreen({Key key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String pageTitle = 'history';
  List<Order> orderList = [];
  List<PaymentType> paymentTypeList = [];
  final storage = FlutterSecureStorage();
  final picker = ImagePicker();
  String imageUrl = '';
  bool imageUpload = false;
  String token = '';
  int storeId = -1;
  int userId = -1;
  String userPhoneNumber = '';

  @override
  void initState() {
    super.initState();

    this.getData();
  }

  void getData() async {
    if (context.read<User>().token == '') {
      return;
    }

    await context.read<User>().updateUser();

    this.token = context.read<User>().token;
    this.imageUrl = context.read<User>().imageUrl;
    this.userId = context.read<User>().id;
    this.userPhoneNumber = context.read<User>().phone;
    this.storeId = context.read<Stores>().storeId;

    await context.read<Orders>().getOrders(this.token);
    await context.read<PaymentTypes>().getPaymentTypes(this.storeId);

    setState(() {
      this.orderList = context.read<Orders>().orderList;
      this.paymentTypeList = context.read<PaymentTypes>().paymentTypeList;
    });
  }

  Widget getOrderItem(Order order) {
    return Container(
        margin: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
        child: OrderCard(
            cardData: order,
            paymentType: this.paymentTypeList.firstWhere((pt) => pt.id == order.paymentTypeId)));
  }

  Widget renderHistory(BuildContext context) {
    if (context.read<User>().token == '') {
      return Container();
    }

    final data = MediaQuery.of(context);

    return this.orderList.length > 0
        ? SingleChildScrollView(
            padding: EdgeInsets.only(top: 20.0),
            child:
                Column(children: this.orderList.map((order) => this.getOrderItem(order)).toList()))
        : Container(
            child: Column(children: [
            Image.asset('assets/images/grey_logo.png'),
            Text(lang.noRecords[lang.langMode],
                style: TextStyle(fontSize: 20.0, color: Color(0xffbfbfbf))),
          ]));
  }

  Widget renderCollection() {
    return Container();
  }

  void uploadImage(PickedFile image) async {
    var url = Uri.parse(serverUrl + '/api/user/update');
    var request = http.MultipartRequest('POST', url);
    //request.fields['id'] = this.userId.toString();
    request.fields['phone'] = this.userPhoneNumber.toString();
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    request.headers['x-access-token'] = token;
    request.headers['Content-Type'] = 'multipart/form-data';

    var response = await request.send();
    var responseBody = jsonDecode(await response.stream.bytesToString());

    if (responseBody['code'] == 200) {
      setState(() {
        this.imageUpload = true;
        this.imageUrl = image.path;
        /*this.imageUrl = responseBody['image_url'];
        if (this.imageUrl == null) {
          this.imageUrl = '';
        }*/
      });
    }
  }

  Future<void> _showImagePickerDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(lang.alert[lang.langMode]),
            content: Text(lang.plzSelectPhotoCameraGallery[lang.langMode]),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final image = await picker.getImage(source: ImageSource.camera);
                    this.uploadImage(image);
                  },
                  child: Text(lang.camera[lang.langMode])),
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final image = await picker.getImage(source: ImageSource.gallery);
                    this.uploadImage(image);
                  },
                  child: Text(lang.gallery[lang.langMode]))
            ],
          );
        });
  }

  Widget renderPhoto(double headerHeight, double photoSize) {
    if (context.read<User>().token == '') {
      return Container();
    }

    return Positioned(
        left: 20.0,
        top: headerHeight - photoSize,
        child: Container(
          height: photoSize,
          width: photoSize,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(color: Color(0x80808080), blurRadius: 10, offset: Offset(0, 0))
          ], borderRadius: BorderRadius.circular(50.0)),
          child: ClipRRect(
              child: this.imageUpload == true
                  ? Image.asset(this.imageUrl, fit: BoxFit.cover)
                  : (this.imageUrl != ''
                      ? Image.network(
                          serverUrl + '/' + this.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Image.asset('assets/images/photo.png', fit: BoxFit.cover)),
              borderRadius: BorderRadius.circular(100.0)),
        ));
  }

  Widget renderName(double headerHeight, double photoSize) {
    if (context.read<User>().token == '') {
      return Container();
    }

    return Positioned(
        left: photoSize + 40,
        top: headerHeight - 30,
        child: Container(
            decoration:
                BoxDecoration(color: Color(0xfffc5671), borderRadius: BorderRadius.circular(20.0)),
            height: 30.0,
            width: 150.0,
            child: Center(
                child: Text(context.watch<User>().name, style: TextStyle(color: Colors.white)))));
  }

  Widget renderImageUploadButton(double headerHeight, double photoSize) {
    if (context.read<User>().token == '') {
      return Container();
    }

    return Positioned(
        left: photoSize,
        top: headerHeight - 30,
        child: GestureDetector(
            onTap: () async {
              this._showImagePickerDialog();
            },
            child: Container(
                decoration: BoxDecoration(
                    color: Color(0xfffc5671), borderRadius: BorderRadius.circular(20.0)),
                height: 30.0,
                width: 30.0,
                child: Icon(
                  Icons.camera_enhance_outlined,
                  color: Colors.white,
                  size: 20.0,
                ))));
  }

  Widget renderSettingsButton() {
    if (context.read<User>().token == '') {
      return Positioned(
          right: 20.0,
          top: 40.0,
          child: TextButton(
              onPressed: () {
                print('Register/Sign In');
                Navigator.of(context).pushNamed(SignInScreen.routeName);
              },
              child: Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(lang.registerSignIn[lang.langMode],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))),
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor: MaterialStateProperty.all(Color(0xfffd677d)),
                  shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0))))));
    } else {
      return Positioned(
          right: 20.0,
          top: 40.0,
          child: IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(SettingsScreen.routeName);
              }));
    }
  }

  Widget renderLabel() {
    if (context.read<User>().token == '') {
      return Container();
    }

    return Container(
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                child: Text(lang.orderHistory[lang.langMode],
                    style: TextStyle(
                        fontSize: 20.0,
                        color: this.pageTitle == 'history' ? Colors.black : Colors.grey)),
                onPressed: () {
                  setState(() {
                    this.pageTitle = 'history';
                  });
                }),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final double headerHeight = data.size.height * 0.25;
    final double photoSize = data.size.height * 0.1;

    return Scaffold(
        body: Container(
            color: Colors.white,
            child: Stack(children: [
              Column(children: [
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.png'), fit: BoxFit.fill)),
                  padding: EdgeInsets.only(top: headerHeight * 0.2),
                  width: data.size.width,
                  height: headerHeight,
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(lang.studystore[lang.langMode],
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white))),
                ),
                this.renderLabel(),
                Expanded(
                    child: this.pageTitle == 'history'
                        ? this.renderHistory(context)
                        : this.renderCollection())
              ]),
              // show photo of user
              this.renderPhoto(headerHeight, photoSize),
              // show name of user
              this.renderName(headerHeight, photoSize),
              // show image upload button
              this.renderImageUploadButton(headerHeight, photoSize),
              // show settings button
              this.renderSettingsButton()
            ])));
  }
}
