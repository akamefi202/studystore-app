import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studystore_app/components/learning_blog_view.dart';
import 'package:studystore_app/modules/string.dart';
import 'package:studystore_app/models/learning_blog.dart';

class LearningCard extends StatefulWidget {
  final LearningBlog cardData;

  LearningCard({Key key, this.cardData}) : super(key: key);
  @override
  _LearningCardState createState() => _LearningCardState();
}

class _LearningCardState extends State<LearningCard> {
  BetterPlayerController _videoPlayerCtrl;
  String orgVideoUrl = '';

  @override
  void initState() {
    super.initState();

    this.initializeVideoPlayer();
    this.orgVideoUrl = widget.cardData.videoUrl;
  }

  void initializeVideoPlayer() {
    BetterPlayerDataSource videoPlayerDataSource =
        BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.cardData.videoUrl);
    this._videoPlayerCtrl = BetterPlayerController(
      BetterPlayerConfiguration(
          controlsConfiguration:
              BetterPlayerControlsConfiguration(enableOverflowMenu: false, enableSkips: false),
          deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
          aspectRatio: 16 / 9,
          fit: BoxFit.contain,
          autoDetectFullscreenDeviceOrientation: false),
      betterPlayerDataSource: videoPlayerDataSource,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('didChangeDependencies');
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerCtrl?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this.orgVideoUrl != widget.cardData.videoUrl) {
      this.initializeVideoPlayer();
      this.orgVideoUrl = widget.cardData.videoUrl;
    }

    return Container(
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Color(0x80808080), blurRadius: 10, offset: Offset(0, 0))],
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0)),
              child: BetterPlayer(controller: this._videoPlayerCtrl)),
          GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return LearningBlogView(viewData: widget.cardData);
                    });
              },
              child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0.0),
                          topRight: Radius.circular(0.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0)),
                      color: Colors.white),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.cardData.title, style: TextStyle(fontSize: 18.0)),
                    Container(height: 5.0),
                    Text(getStringFromDate(widget.cardData.date),
                        style: TextStyle(color: Colors.grey))
                  ])))
        ],
      ),
    );
  }
}
