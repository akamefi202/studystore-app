import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/components/rounded_button.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/screens/dashboard.dart';
import 'package:studystore_app/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/constants/config.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:flutter_svg/flutter_svg.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = 'screens/sign_in';

  SignInScreen({Key key}) : super(key: key);
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _phoneNumberCtrl;
  TextEditingController _veriCodeCtrl;
  TextEditingController _passwordCtrl;
  final storage = FlutterSecureStorage();
  bool isLoading = false;
  String loginType = 'code';
  bool waitingCode = false;
  int waitingSeconds = 60;
  Timer _timer;

  @override
  void initState() {
    super.initState();

    _phoneNumberCtrl = TextEditingController();
    _veriCodeCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void signIn() async {
    if (this._phoneNumberCtrl.text == "" ||
        (this.loginType == 'code' && this._veriCodeCtrl.text == "") ||
        (this.loginType == 'password' && this._passwordCtrl.text == "")) {
      this.showAlertDialog(
          lang.warning[lang.langMode], lang.plzInputAllFieldCorrectly[lang.langMode]);
      return;
    }

    setState(() {
      this.isLoading = true;
    });

    try {
      Map<String, Object> responseBody = await context.read<User>().signIn(_phoneNumberCtrl.text,
          this.loginType == 'code' ? _veriCodeCtrl.text : _passwordCtrl.text);

      if (responseBody['code'] == 200) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(DashboardScreen.routeName, (Route<dynamic> route) => false);

        // save token to storage
        await storage.write(key: 'studystore_token', value: responseBody['accessToken']);
        await storage.write(key: 'studystore_id', value: responseBody['id'].toString());
      } else {
        this.showAlertDialog(lang.warning[lang.langMode], lang.invalidCode[lang.langMode]);
      }
    } catch (error) {
      this.showAlertDialog(lang.error[lang.langMode], lang.serverError[lang.langMode]);
    }

    setState(() {
      this.isLoading = false;
    });
  }

  void sendCode() async {
    if (this._phoneNumberCtrl.text == "") {
      this.showAlertDialog(
          lang.warning[lang.langMode], lang.plzInputAllFieldCorrectly[lang.langMode]);
      return;
    }

    // starts 60 seconds timer
    setState(() {
      this.waitingCode = true;
      this.waitingSeconds = 60;
    });

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (this.waitingSeconds == 0) {
        setState(() {
          timer.cancel();
          this.waitingCode = false;
        });
      } else {
        setState(() {
          this.waitingSeconds--;
        });
      }
    });

    try {
      var url = Uri.parse(serverUrl + '/api/user/phone_code');
      var body = jsonEncode({"phone": _phoneNumberCtrl.text});

      var response =
          await http.post(url, body: body, headers: {"Content-Type": "application/json"});
      var responseBody = jsonDecode(response.body);
      print(response.body);

      if (responseBody['code'] != 200) {
        this.showAlertDialog(lang.error[lang.langMode], lang.couldNotSendCode[lang.langMode]);
      }
    } catch (error) {
      this.showAlertDialog(lang.error[lang.langMode], lang.serverError[lang.langMode]);
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

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: LoadingOverlay(
            isLoading: this.isLoading,
            child: SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.only(left: 50, right: 50),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(height: 80.0),
                        Container(width: 150, child: Image.asset('assets/images/white_logo.png')),
                        Container(height: 40.0),
                        Container(
                            padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            decoration: BoxDecoration(
                                color: Color(0x10000000),
                                borderRadius: BorderRadius.all(Radius.circular(50.0))),
                            child:
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Container(
                                  width: data.size.width * 0.5,
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    controller: _phoneNumberCtrl,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: lang.phoneNumber[lang.langMode]),
                                  )),
                              SvgPicture.asset('assets/icons/phone.svg')
                            ])),
                        Container(height: 20.0),
                        this.loginType == 'code'
                            ? Container(
                                padding: EdgeInsets.only(left: 20.0, right: 10.0),
                                decoration: BoxDecoration(
                                    color: Color(0x10000000),
                                    borderRadius: BorderRadius.all(Radius.circular(50.0))),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          width: data.size.width * 0.25,
                                          child: TextField(
                                            keyboardType: TextInputType.number,
                                            controller: _veriCodeCtrl,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(6)
                                            ],
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: lang.veriCode[lang.langMode]),
                                          )),
                                      this.waitingCode == false
                                          ? TextButton(
                                              onPressed: this.sendCode,
                                              child: Text(lang.send[lang.langMode],
                                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                              style: ButtonStyle(
                                                  foregroundColor:
                                                      MaterialStateProperty.all(Colors.white),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(foreColor),
                                                  shape: MaterialStateProperty.all(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(10.0)))))
                                          : Text(
                                              this.waitingSeconds.toString() +
                                                  lang.secondsLater[lang.langMode] +
                                                  '  ',
                                              style: TextStyle(color: Colors.grey))
                                    ]))
                            : Container(
                                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                                decoration: BoxDecoration(
                                    color: Color(0x10000000),
                                    borderRadius: BorderRadius.all(Radius.circular(50.0))),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          width: data.size.width * 0.5,
                                          child: TextField(
                                            obscureText: true,
                                            controller: _passwordCtrl,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: lang.password[lang.langMode]),
                                          )),
                                      SvgPicture.asset('assets/icons/password.svg')
                                    ])),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          this.loginType == 'code'
                              ? TextButton(
                                  onPressed: () {
                                    setState(() {
                                      this.loginType = 'password';
                                    });
                                  },
                                  child: Text(lang.usePasswordForVerfi[lang.langMode],
                                      style: TextStyle(color: foreColor)))
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      this.loginType = 'code';
                                    });
                                  },
                                  child: Text(lang.usePhoneCodeForVeri[lang.langMode],
                                      style: TextStyle(color: foreColor)),
                                )
                        ]),
                        Container(height: 40.0),
                        Container(
                            width: double.infinity,
                            child: RoundedButton(
                                onPressed: this.signIn,
                                title: this.loginType == 'code'
                                    ? lang.signInRegister[lang.langMode]
                                    : lang.signIn[lang.langMode],
                                type: 0)),
                        Container(height: 20.0),
                      ],
                    )))));
  }
}
