import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/models/announcement.dart';

class AnnouncementView extends StatefulWidget {
  final Announcement viewData;

  AnnouncementView({Key key, this.viewData}) : super(key: key);
  @override
  _AnnouncementViewState createState() => _AnnouncementViewState();
}

class _AnnouncementViewState extends State<AnnouncementView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
      color: Colors.white,
      child: Column(
        children: [
          Row(children: [
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                })
          ], mainAxisAlignment: MainAxisAlignment.start),
          Container(
            height: 20.0,
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Container(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(widget.viewData.title,
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                        Container(
                          height: 20.0,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(widget.viewData.imageUrl,
                              width: double.infinity, fit: BoxFit.cover),
                        ),
                        Container(
                          height: 20.0,
                        ),
                        Html(data: widget.viewData.content)
                      ]))))
        ],
      ),
    ));
  }
}
