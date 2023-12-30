import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/constants/colors.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/screens/dashboard.dart';
import 'package:studystore_app/screens/sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:expandable/expandable.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:package_info/package_info.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = 'screens/settings';

  SettingsScreen({Key key}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController _nameCtrl;
  TextEditingController _newPasswordCtrl;
  TextEditingController _confirmPasswordCtrl;
  final storage = FlutterSecureStorage();
  int userId = -1;
  String userPhoneNumber = '';
  String token = '';
  bool loading = false;
  String currentVersion = '';
  String latestVersion = '';

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController();
    _newPasswordCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();

    this.token = Provider.of<User>(context, listen: false).token;
    this.userId = Provider.of<User>(context, listen: false).id;
    this.userPhoneNumber = Provider.of<User>(context, listen: false).phone;

    getName();
    getVersion();
  }

  void getName() async {
    _nameCtrl.text = Provider.of<User>(context, listen: false).name;
  }

  void getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      this.currentVersion = packageInfo.version;
      this.latestVersion = packageInfo.version;
    });
  }

  void updatePassword() async {
    if (_newPasswordCtrl.text == "" ||
        _confirmPasswordCtrl.text == "" ||
        _newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      showAlertDialog(lang.alert[lang.langMode], lang.plzInputPwdCorrectly[lang.langMode]);
      return;
    }

    setState(() {
      this.loading = true;
    });

    var responseBody = await context.read<User>().updatePassword(_newPasswordCtrl.text);

    setState(() {
      this.loading = false;
    });

    if (responseBody['code'] == 200) {
      this.showAlertDialog(lang.success[lang.langMode], lang.pwdIsUpdateSuccess[lang.langMode]);
    } else {
      this.showAlertDialog(lang.error[lang.langMode], lang.pwdUpdateFailed[lang.langMode]);
    }
  }

  void updateName() async {
    if (_nameCtrl.text == "") {
      showAlertDialog(lang.alert[lang.langMode], lang.plzInputNameCorrectly[lang.langMode]);
      return;
    }

    setState(() {
      this.loading = true;
    });

    var responseBody = await context.read<User>().updateName(this._nameCtrl.text);

    setState(() {
      this.loading = false;
    });

    if (responseBody['code'] == 200) {
      this.showAlertDialog(lang.success[lang.langMode], lang.nameUpdateSuccess[lang.langMode]);
    } else {
      this.showAlertDialog(lang.error[lang.langMode], lang.nameUpdateFailed[lang.langMode]);
    }
  }

  Future<void> showAlertDialog(String title, String content) async {
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

  Future<void> showSignOutDialog(
    String title,
    String content,
  ) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              ButtonBar(alignment: MainAxisAlignment.spaceAround, children: [
                OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                        padding:
                            MaterialStateProperty.all(EdgeInsets.only(left: 10.0, right: 10.0)),
                        foregroundColor: MaterialStateProperty.all(Colors.grey[700]),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)))),
                    child: Text(lang.cancel1[lang.langMode])),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);

                      storage.delete(key: 'studystore_token');
                      storage.delete(key: 'studystore_id');
                      context.read<User>().signOut();
                      /*Navigator.of(context).pushNamedAndRemoveUntil(
                          SignInScreen.routeName, (Route<dynamic> route) => false);*/
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          DashboardScreen.routeName, (Route<dynamic> route) => false);
                    },
                    style: ButtonStyle(
                        padding:
                            MaterialStateProperty.all(EdgeInsets.only(left: 10.0, right: 10.0)),
                        backgroundColor: MaterialStateProperty.all(Colors.grey[700]),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)))),
                    child: Text(lang.confirm[lang.langMode]))
              ])
            ],
          );
        });
  }

  Widget renderNameItem(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]))),
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0),
        child: ExpandablePanel(
            theme: ExpandableThemeData(
                iconColor: Colors.grey,
                iconSize: 30.0,
                headerAlignment: ExpandablePanelHeaderAlignment.center),
            header: Text(lang.name[lang.langMode], style: TextStyle(fontSize: 16.0)),
            expanded: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    decoration: BoxDecoration(
                        color: Color(0x10000000),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: TextField(
                      keyboardType: TextInputType.name,
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: lang.name[lang.langMode]),
                    )),
                Container(
                  height: 10.0,
                ),
                TextButton(
                    onPressed: this.updateName,
                    child: Text(lang.save[lang.langMode], style: TextStyle(color: foreColor)))
              ]),
            ),
            collapsed: Container()));
  }

  Widget renderPasswordItem() {
    return Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]))),
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0),
        child: ExpandablePanel(
            theme: ExpandableThemeData(
                iconColor: Colors.grey,
                iconSize: 30.0,
                headerAlignment: ExpandablePanelHeaderAlignment.center),
            header: Text(lang.password[lang.langMode], style: TextStyle(fontSize: 16.0)),
            expanded: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    decoration: BoxDecoration(
                        color: Color(0x10000000),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: TextField(
                      obscureText: true,
                      controller: _newPasswordCtrl,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: lang.newPassword[lang.langMode]),
                    )),
                Container(height: 10.0),
                Container(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    decoration: BoxDecoration(
                        color: Color(0x10000000),
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: TextField(
                      obscureText: true,
                      controller: _confirmPasswordCtrl,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: lang.confirmPassword[lang.langMode]),
                    )),
                Container(height: 10.0),
                TextButton(
                    onPressed: this.updatePassword,
                    child: Text(lang.save[lang.langMode], style: TextStyle(color: foreColor))),
              ]),
            ),
            collapsed: Container()));
  }

  Widget renderUpgradeItem() {
    return Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]))),
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0),
        child: ExpandablePanel(
            theme: ExpandableThemeData(
                iconColor: Colors.grey,
                iconSize: 30.0,
                headerAlignment: ExpandablePanelHeaderAlignment.center),
            header: Text(lang.upgrade[lang.langMode], style: TextStyle(fontSize: 16.0)),
            expanded: Container(
              padding: EdgeInsets.all(10.0),
              child: Container(),
            ),
            collapsed: Container()));
  }

  Widget renderSignOutItem() {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]))),
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(lang.signOut[lang.langMode], style: TextStyle(fontSize: 16.0)),
          IconButton(
              icon: Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.grey,
                size: 20.0,
              ),
              onPressed: () {
                this.showSignOutDialog(
                    lang.signOut[lang.langMode], lang.askIfExitCode[lang.langMode]);
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LoadingOverlay(
          isLoading: this.loading,
          child: Container(
              padding: EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: SingleChildScrollView(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    lang.settings[lang.langMode],
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 10.0,
                  ),
                  this.renderNameItem(context),
                  this.renderPasswordItem(),
                  this.renderUpgradeItem(),
                  this.renderSignOutItem()
                ]))),
                Container(height: 20.0),
                Row(children: [
                  Text(lang.currentVersion[lang.langMode] + ': ', style: TextStyle(fontSize: 16)),
                  Text(this.currentVersion,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(', ' + lang.latestVersion[lang.langMode] + ': ',
                      style: TextStyle(fontSize: 16)),
                  Text(this.latestVersion,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ])
              ]))),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }
}
