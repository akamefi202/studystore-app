import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studystore_app/models/learning_blog.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/models/announcement.dart';

class LearningBlogView extends StatefulWidget {
  final LearningBlog viewData;

  LearningBlogView({Key key, this.viewData}) : super(key: key);
  @override
  _LearningBlogViewState createState() => _LearningBlogViewState();
}

class _LearningBlogViewState extends State<LearningBlogView> {
  BetterPlayerController _videoPlayerCtrl;

  @override
  void initState() {
    super.initState();

    BetterPlayerDataSource videoPlayerDataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.viewData.videoUrl);
    this._videoPlayerCtrl = BetterPlayerController(
        BetterPlayerConfiguration(
            controlsConfiguration: BetterPlayerControlsConfiguration(enableOverflowMenu: false),
            deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
            aspectRatio: 16 / 9,
            fit: BoxFit.fitHeight),
        betterPlayerDataSource: videoPlayerDataSource);
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerCtrl?.dispose();
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
                        BetterPlayer(controller: this._videoPlayerCtrl),
                        Container(height: 20.0),
                        Row(
                          children: [
                            Text(lang.title[lang.langMode] + ': ',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                            Text(widget.viewData.title, style: TextStyle(fontSize: 18.0))
                          ],
                        ),
                        Container(
                          height: 20.0,
                        ),
                        Text(lang.explanation[lang.langMode] + ':',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                        Html(data: widget.viewData.content)
                      ]))))
        ],
      ),
    ));
  }
}
