import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluwx/fluwx.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:studystore_app/providers/messages.dart';
import 'package:studystore_app/screens/home.dart';
import 'package:studystore_app/screens/dashboard.dart';
import 'package:studystore_app/screens/payment_types.dart';
import 'package:studystore_app/screens/recharge.dart';
import 'package:studystore_app/screens/news.dart';
import 'package:studystore_app/screens/order.dart';
import 'package:studystore_app/screens/profile.dart';
import 'package:studystore_app/screens/product_selection.dart';
import 'package:studystore_app/screens/settings.dart';
import 'package:studystore_app/screens/sign_in.dart';
import 'package:studystore_app/screens/payment.dart';
import 'package:studystore_app/screens/store_selection.dart';
import 'package:studystore_app/screens/learning_blogs.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/providers/stores.dart';
import 'package:studystore_app/providers/payment_types.dart';
import 'package:studystore_app/providers/products.dart';
import 'package:studystore_app/providers/orders.dart';

var routes = <String, WidgetBuilder>{
  HomeScreen.routeName: (BuildContext context) => HomeScreen(),
  DashboardScreen.routeName: (BuildContext context) => DashboardScreen(),
  PaymentTypesScreen.routeName: (BuildContext context) => PaymentTypesScreen(),
  NewsScreen.routeName: (BuildContext context) => NewsScreen(),
  OrderScreen.routeName: (BuildContext context) => OrderScreen(),
  ProfileScreen.routeName: (BuildContext context) => ProfileScreen(),
  ProductSelectionScreen.routeName: (BuildContext context) => ProductSelectionScreen(),
  SettingsScreen.routeName: (BuildContext context) => SettingsScreen(),
  SignInScreen.routeName: (BuildContext context) => SignInScreen(),
  PaymentScreen.routeName: (BuildContext context) => PaymentScreen(),
  StoreSelectionScreen.routeName: (BuildContext context) => StoreSelectionScreen(),
  LearningBlogsScreen.routeName: (BuildContext context) => LearningBlogsScreen(),
  RechargeScreen.routeName: (BuildContext context) => RechargeScreen()
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: User()),
    ChangeNotifierProvider.value(value: Stores()),
    ChangeNotifierProvider.value(value: Products()),
    ChangeNotifierProvider.value(value: PaymentTypes()),
    ChangeNotifierProvider.value(value: Orders()),
    ChangeNotifierProvider.value(value: Messages()),
  ], child: MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp();
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    this.initFluwx();
    //this.loadAssetImages();
    // show splash screen for more than 3 seconds
    sleep(Duration(milliseconds: 3000));
  }

  Future<void> initFluwx() async {
    await registerWxApi(
        appId: fluwxAppId,
        doOnAndroid: true,
        doOnIOS: true,
        universalLink: 'https://help.wechat.com/app/');
    var result = await isWeChatInstalled;
    print("wechat is installed: $result");
  }

  // precache images
  void loadAssetImages() {
    precacheImage(AssetImage("assets/images/logo.png"), context);
    precacheImage(AssetImage("assets/images/white_logo.png"), context);
    precacheImage(AssetImage("assets/images/store.png"), context);
    precacheImage(AssetImage("assets/images/meeting_room.png"), context);
    precacheImage(AssetImage("assets/images/qrcode_ios.png"), context);
    precacheImage(AssetImage("assets/images/photo.png"), context);
    precacheImage(AssetImage("assets/images/second_floor.png"), context);
    precacheImage(AssetImage("assets/images/third_floor.png"), context);
    precacheImage(AssetImage("assets/images/first_floor1.png"), context);
    precacheImage(AssetImage("assets/images/second_floor1.png"), context);
    precacheImage(AssetImage("assets/images/third_floor1.png"), context);
    precacheImage(AssetImage("assets/images/background.png"), context);
    precacheImage(AssetImage("assets/images/wechat.png"), context);
    precacheImage(AssetImage("assets/images/recharge.png"), context);
    precacheImage(AssetImage("assets/icons/location.svg"), context);
    precacheImage(AssetImage("assets/icons/mail.svg"), context);
    precacheImage(AssetImage("assets/icons/message.svg"), context);
    precacheImage(AssetImage("assets/icons/password.svg"), context);
    precacheImage(AssetImage("assets/icons/phone.svg"), context);
    precacheImage(AssetImage("assets/icons/profile.svg"), context);
    precacheImage(AssetImage("assets/icons/qrcode.svg"), context);
    precacheImage(AssetImage("assets/icons/home.svg"), context);
    precacheImage(AssetImage("assets/icons/home1.svg"), context);
    precacheImage(AssetImage("assets/icons/learning.svg"), context);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus.unfocus();
          }
        },
        child: MaterialApp(
          theme: ThemeData(
              primarySwatch: Colors.blue,
              appBarTheme: AppBarTheme(
                  backgroundColor: Colors.white,
                  textTheme: TextTheme(headline6: TextStyle(color: Colors.black, fontSize: 20.0)))
              //visualDensity: VisualDensity.adaptivePlatformDensity
              ),
          home: DashboardScreen() /*SignInScreen()*/,
          routes: routes,
          debugShowCheckedModeBanner: false,
        ));
  }
}
