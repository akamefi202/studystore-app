import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studystore_app/providers/messages.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/screens/home.dart';
import 'package:studystore_app/screens/news.dart';
import 'package:studystore_app/screens/recharge.dart';
import 'package:studystore_app/screens/learning_blogs.dart';
import 'package:studystore_app/screens/profile.dart';
import 'package:studystore_app/screens/payment_types.dart';
import 'package:studystore_app/constants/colors.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = 'screens/dashboard';

  DashboardScreen({Key key}) : super(key: key);
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selIndex = 0;
  List<Widget> _widgetOptions = [
    HomeScreen(),
    NewsScreen(),
    PaymentTypesScreen(),
    LearningBlogsScreen(),
    ProfileScreen()
  ];
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    this.tryAutoSignIn();
  }

  void tryAutoSignIn() async {
    String _token = await storage.read(key: 'studystore_token');
    String _id = await storage.read(key: 'studystore_id');

    if (_token != null) {
      context.read<User>().token = _token;
      context.read<User>().id = int.parse(_id);

      if (await context.read<User>().updateUser() == false) {
        // if token has a problem, clear token and id
        storage.delete(key: 'studystore_token');
        storage.delete(key: 'studystore_id');

        context.read<User>().token = '';
        context.read<User>().id = -1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: this._widgetOptions.elementAt(this.selIndex),
        bottomNavigationBar:
            /*FancyBottomNavigation(
            tabs: [
              TabData(iconData: Icons.home, title: ''),
              TabData(iconData: Icons.home, title: ''),
              TabData(iconData: Icons.home, title: ''),
              TabData(iconData: Icons.home, title: ''),
              TabData(iconData: Icons.home, title: ''),
            ],
            onTabChangedListener: (index) {
              setState(() {
                selIndex = index;
              });
            })*/
            SizedBox(
                child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: this.selIndex == 0
                    ? SvgPicture.asset('assets/icons/selected_home.svg')
                    : SvgPicture.asset('assets/icons/home.svg'),
                label: ''),
            BottomNavigationBarItem(
                icon: Badge(
                    child: this.selIndex == 1
                        ? SvgPicture.asset('assets/icons/selected_message.svg')
                        : SvgPicture.asset('assets/icons/message.svg'),
                    badgeContent: Text(context.watch<Messages>().newMsgCount.toString(),
                        style: TextStyle(color: Colors.white)),
                    showBadge: context.watch<Messages>().newMsgCount != 0),
                label: ''),
            BottomNavigationBarItem(
                icon: this.selIndex == 2
                    ? SvgPicture.asset('assets/icons/selected_card.svg')
                    : SvgPicture.asset('assets/icons/card.svg'),
                label: ''),
            BottomNavigationBarItem(
                icon: this.selIndex == 3
                    ? SvgPicture.asset('assets/icons/selected_learning.svg')
                    : SvgPicture.asset('assets/icons/learning.svg'),
                label: ''),
            BottomNavigationBarItem(
                icon: this.selIndex == 4
                    ? SvgPicture.asset('assets/icons/selected_profile.svg')
                    : SvgPicture.asset('assets/icons/profile.svg'),
                label: '')
          ],
          currentIndex: this.selIndex,
          onTap: (index) {
            setState(() {
              selIndex = index;
            });
          },
        )));
  }
}
