import 'package:flutter/material.dart';
import 'package:studystore_app/components/announcement_view.dart';
import 'package:studystore_app/modules/string.dart';
import 'package:studystore_app/models/announcement.dart';

class AnnouncementCard extends StatefulWidget {
  final Announcement cardData;

  AnnouncementCard({Key key, this.cardData}) : super(key: key);
  @override
  _AnnouncementCardState createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AnnouncementView(viewData: widget.cardData);
              });
        },
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(color: Color(0x80808080), blurRadius: 10, offset: Offset(0, 0))
          ], borderRadius: BorderRadius.circular(10.0), color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
                child: Image.network(widget.cardData.imageUrl,
                    height: data.size.height * 0.2, width: double.infinity, fit: BoxFit.cover),
              ),
              Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.cardData.title, style: TextStyle(fontSize: 18.0)),
                    Container(height: 5.0),
                    Text(getStringFromDate(widget.cardData.date),
                        style: TextStyle(color: Colors.grey))
                  ]))
            ],
          ),
        ));
  }
}
