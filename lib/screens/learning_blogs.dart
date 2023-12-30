import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/components/learning_blog_card.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/components/rounded_button.dart';
import 'package:studystore_app/models/learning_blog.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:http/http.dart' as http;

class LearningBlogsScreen extends StatefulWidget {
  static const routeName = 'screens/learning';

  LearningBlogsScreen({Key key}) : super(key: key);
  @override
  _LearningBlogsScreenState createState() => _LearningBlogsScreenState();
}

class _LearningBlogsScreenState extends State<LearningBlogsScreen> {
  List<LearningBlog> learningBlogList = [];
  List<LearningBlog> showBlogList = [];
  List<String> learningBlogTypeList = [];
  String token = '';
  String searchText = '';
  String selectedType = lang.all[lang.langMode];

  @override
  void initState() {
    super.initState();

    this.token = context.read<User>().token;

    this.getData();
  }

  Future<void> getData() async {
    await this.getLearningBlogTypes();
    await this.getLearningBlogs();
  }

  Future<void> getLearningBlogTypes() async {
    var url = Uri.parse(serverUrl + '/api/studycontenttype/list');
    var body = jsonEncode({"key": "", "offset": 0, "pagesize": pageSizeLimit});

    var response = await http.post(url,
        body: body, headers: {"Content-Type": "application/json", "x-access-token": this.token});
    var responseBody = jsonDecode(response.body);

    List<Object> blogs = responseBody['data'];
    List<String> finalTypeList = [];

    blogs.forEach((element) {
      Map<String, Object> type = element;
      finalTypeList.add(type['name']);
    });

    finalTypeList.insert(0, lang.all[lang.langMode]);

    setState(() {
      this.learningBlogTypeList = finalTypeList;
    });
  }

  Future<void> getLearningBlogs() async {
    var url = Uri.parse(serverUrl + '/api/studycontent/list');
    var body = jsonEncode({"key": "", "offset": 0, "pagesize": pageSizeLimit});

    var response = await http.post(url,
        body: body, headers: {"Content-Type": "application/json", "x-access-token": this.token});
    var responseBody = jsonDecode(response.body);

    List<Object> blogs = responseBody['data'];
    List<LearningBlog> finalBlogList = [];

    blogs.forEach((element) {
      Map<String, Object> blog = element;
      finalBlogList.add(LearningBlog.fromJson(blog));
    });

    setState(() {
      this.learningBlogList = finalBlogList;
      this.showBlogList = finalBlogList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Scaffold(
        body: Container(
            padding: EdgeInsets.only(top: 60.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Text(lang.learning[lang.langMode],
                      style: TextStyle(
                          color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold))),
              Container(height: 20.0),
              Container(
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  decoration: BoxDecoration(
                      color: Color(0x10000000),
                      borderRadius: BorderRadius.all(Radius.circular(50.0))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Icon(Icons.search_outlined),
                    Container(width: 10.0),
                    Container(
                        width: data.size.width * 0.5,
                        child: TextField(
                          onChanged: (value) {
                            this.setState(() {
                              this.searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: lang.search[lang.langMode]),
                        )),
                    Container(height: 20.0),
                  ])),
              Container(height: 10.0),
              Container(
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Row(
                      children: this
                          .learningBlogTypeList
                          .map((e) => TextButton(
                              onPressed: () {
                                setState(() {
                                  // show learning blogs for only adults
                                  this.selectedType = e;
                                  if (e == lang.all[lang.langMode]) {
                                    this.showBlogList = this.learningBlogList;
                                  } else {
                                    this.showBlogList = [];
                                    this.learningBlogList.forEach((element) {
                                      if (element.type == this.selectedType) {
                                        showBlogList.add(element);
                                      }
                                    });
                                    /*this.showBlogList = this
                                        .learningBlogList
                                        .where((element) => element.type == this.selectedType)
                                        .toList();*/
                                  }
                                });
                              },
                              child: Text(e,
                                  style: TextStyle(
                                      color: this.selectedType == e ? Colors.black : Colors.grey,
                                      fontSize: 16.0))))
                          .toList())),
              Container(height: 10.0),
              Expanded(
                  child: SingleChildScrollView(
                      child: Container(
                          margin: EdgeInsets.only(top: 20.0),
                          child: Column(
                              children: this
                                  .showBlogList
                                  .where((element) => element.title.contains(this.searchText))
                                  .map((e) => Container(
                                        padding:
                                            EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
                                        child: LearningCard(cardData: e),
                                      ))
                                  .toList())))),
            ])));
  }
}
