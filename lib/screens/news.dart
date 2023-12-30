import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/components/announcement_card.dart';
import 'package:studystore_app/models/message.dart';
import 'package:studystore_app/models/announcement.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:studystore_app/modules/string.dart';
//import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studystore_app/providers/messages.dart';
import 'package:studystore_app/providers/stores.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/screens/sign_in.dart';

class NewsScreen extends StatefulWidget {
  static const routeName = 'screens/news';

  NewsScreen({Key key}) : super(key: key);
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  TextEditingController _messageCtrl;
  ScrollController _msgScrollCtrl;
  String pageTitle = "news"; // "news" or "message"
  List<Message> msgList = [];
  List<Announcement> newsAnnoList = [];
  final storage = FlutterSecureStorage();
  String username;
  String image;
  int storeId;
  String token;
  SocketIO socketIO;
  int messageCount = 10;

  @override
  void initState() {
    super.initState();

    _messageCtrl = TextEditingController();
    _msgScrollCtrl = ScrollController();
    _msgScrollCtrl.addListener(() {
      if (_msgScrollCtrl.offset >= _msgScrollCtrl.position.maxScrollExtent &&
          !_msgScrollCtrl.position.outOfRange) {
        messageCount = messageCount + 10;
        getMessages();
      }
    });

    getData();
    getNewsAnnouncements();
    getMessages();
    initSocket();
  }

  void getData() {
    this.token = Provider.of<User>(context, listen: false).token;
    this.username = Provider.of<User>(context, listen: false).username;
    this.image = Provider.of<User>(context, listen: false).imageUrl;
    if (this.image == null) {
      this.image = '';
    }
    this.storeId = Provider.of<Stores>(context, listen: false).storeId;
  }

  void initSocket() async {
    /*socketIO = SocketIOManager()
        .createSocketIO(serverUrl, '/', query: 'chatID=${this.username}');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      var finalMsgList = this.msgList;
      finalMsgList.add(Message(
          sender: 'admin', text: data['content'], datetime: data['datetime']));

      setState(() {
        this.msgList = finalMsgList;
      });
    });

    socketIO.connect();

    IO.Socket socket = IO.io(serverUrl);
    socket.onConnect((data) {
      socket.emit('message', 'test');
    });

    socket.connect();*/
  }

  void sendMessage(String text) async {
    if (text == '') {
      return;
    }

    setState(() {
      msgList.insert(0, Message(text: text, sender: this.username, datetime: DateTime.now()));
    });

    /*socketIO.sendMessage(
      'send_message',
      json.encode({
        'receiverChatID': 'admin',
        'senderChatID': this.username,
        'content': text,
      }),
    );*/

    var url = Uri.parse(serverUrl + '/api/message/create');
    var body = jsonEncode({
      "sender": this.username,
      "receivers": "",
      "store_id": this.storeId,
      "message": text,
      "is_opened": 1
    });

    var response = await http.post(url,
        body: body, headers: {"Content-Type": "application/json", "x-access-token": this.token});
  }

  void getNewsAnnouncements() async {
    var url = Uri.parse(serverUrl + '/api/announcement/list');
    var body = jsonEncode({"key": "", "offset": 0, "pagesize": pageSizeLimit, "type": 1});

    var response = await http.post(url, body: body, headers: {"Content-Type": "application/json"});
    var responseBody = jsonDecode(response.body);

    List<Object> ans = responseBody['data'];
    List<Announcement> finalNewsAnnoList = [];

    ans.forEach((element) {
      Map<String, Object> an = element;
      finalNewsAnnoList.add(Announcement.fromJson(an));
    });

    setState(() {
      this.newsAnnoList = finalNewsAnnoList;
    });
  }

  void getMessages() async {
    if (context.read<User>().token == '') {
      return;
    }

    var url = Uri.parse(serverUrl + '/api/message/list');
    var body = jsonEncode(
        {"username": this.username, "key": "", "offset": 0, "pagesize": this.messageCount});

    var response = await http.post(url,
        body: body, headers: {"Content-Type": "application/json", "x-access-token": this.token});
    var responseBody = jsonDecode(response.body);

    List<Object> messages = responseBody['data'];
    List<Message> finalMsgList = [];

    messages.forEach((element) {
      Map<String, Object> an = element;
      finalMsgList.add(Message.fromJson(an));
    });

    setState(() {
      this.msgList = finalMsgList;
    });
  }

  Widget renderNews() {
    return Expanded(
        child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                child: Column(
                    children: this
                        .newsAnnoList
                        .map((anno) => Container(
                            margin: EdgeInsets.only(bottom: 20.0),
                            child: AnnouncementCard(cardData: anno)))
                        .toList()))));
  }

  Widget renderMessages(BuildContext context) {
    List<Widget> items = [];
    String latestDate = '2000.01.01';
    final data = MediaQuery.of(context);

    msgList.reversed.forEach((message) {
      if (latestDate != getStringFromDate(message.datetime)) {
        latestDate = getStringFromDate(message.datetime);

        items.add(Container(
            margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            decoration:
                BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10.0)),
            child: Text(
              latestDate,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            )));
      }

      if (message.sender != this.username) {
        items.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0),
                height: 50.0,
                width: 50.0,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0), boxShadow: [
                  BoxShadow(color: Color(0x80808080), blurRadius: 5, offset: Offset(0, 0))
                ]),
                child: ClipRRect(
                  child: Image.asset(
                    'assets/images/white_logo.png',
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                )),
            Container(width: 10.0),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  constraints: BoxConstraints(maxWidth: data.size.width * 0.6),
                  margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(color: Color(0x80808080), blurRadius: 5, offset: Offset(0, 0))
                      ]),
                  child: Text(message.text)),
              Text(getStringFromTime(message.datetime))
            ])
          ])
        ]));
      } else {
        items.add(Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                  constraints: BoxConstraints(maxWidth: data.size.width * 0.6),
                  margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(color: Color(0x80ff6265), blurRadius: 5, offset: Offset(0, 0))
                      ]),
                  child: Text(message.text)),
              Text(getStringFromTime(message.datetime))
            ]),
            Container(width: 10.0),
            Container(
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0),
                height: 50.0,
                width: 50.0,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0), boxShadow: [
                  BoxShadow(color: Color(0x80808080), blurRadius: 5, offset: Offset(0, 0))
                ]),
                child: ClipRRect(
                  child: this.image == ''
                      ? Image.asset(
                          'assets/images/photo.png',
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          serverUrl + '/' + this.image,
                          fit: BoxFit.cover,
                        ),
                  borderRadius: BorderRadius.circular(50.0),
                ))
          ])
        ]));
      }
    });

    return Expanded(
        child: Container(
            child: Column(children: [
      Expanded(
          //height: data.size.height * 0.5,
          child: SingleChildScrollView(
              reverse: true,
              controller: this._msgScrollCtrl,
              child: Container(
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Column(children: items)))),
      Container(
          margin: EdgeInsets.only(left: 20.0, right: 20.0),
          padding: EdgeInsets.only(left: 20.0),
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Color(0x80808080), blurRadius: 5, offset: Offset(0, 0))],
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                controller: this._messageCtrl,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: lang.typeYourMessage[lang.langMode]),
              )),
              IconButton(
                  icon: SvgPicture.asset('assets/icons/mail.svg'),
                  onPressed: () {
                    this.sendMessage(this._messageCtrl.text);
                    setState(() {
                      this._messageCtrl.clear();
                    });
                  })
            ],
          )),
      Container(height: 20.0),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(top: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                this.pageTitle == 'news' ? lang.news[lang.langMode] : lang.myMessage[lang.langMode],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),
              )),
          Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Row(
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          pageTitle = 'news';
                        });
                      },
                      child: Text(
                        lang.news[lang.langMode],
                        style: TextStyle(
                            fontSize: 16.0,
                            color: pageTitle == 'news' ? Colors.black : Colors.grey),
                      )),
                  TextButton(
                    onPressed: () {
                      if (context.read<User>().token == '') {
                        Navigator.of(context).pushNamed(SignInScreen.routeName);
                        return;
                      }

                      context.read<Messages>().updateNewMsgCount(0);

                      setState(() {
                        pageTitle = 'message';
                      });
                    },
                    child: Text(lang.myMessage[lang.langMode],
                        style: TextStyle(
                            fontSize: 16.0,
                            color: pageTitle == 'message' ? Colors.black : Colors.grey)),
                  )
                ],
              )),
          pageTitle == 'news' ? renderNews() : renderMessages(context)
        ],
      ),
    ));
  }
}
