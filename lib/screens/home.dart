import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:studystore_app/constants/config.dart';
import 'package:studystore_app/constants/lang.dart' as lang;
import 'package:studystore_app/constants/colors.dart';
import 'package:studystore_app/components/announcement_card.dart';
import 'package:studystore_app/models/announcement.dart';
import 'package:studystore_app/models/advertisement.dart';
import 'package:studystore_app/providers/messages.dart';
import 'package:studystore_app/providers/products.dart';
import 'package:studystore_app/providers/stores.dart';
import 'package:studystore_app/providers/user.dart';
import 'package:studystore_app/screens/order.dart';
import 'package:studystore_app/screens/sign_in.dart';
import 'package:studystore_app/screens/store_selection.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = 'screens/home';

  HomeScreen({Key key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Announcement> mainAnnoList = [];
  List<Advertisement> advertisementList = [];
  String storeName = lang.yanjiWandaStore[lang.langMode];
  int storeId = -1;
  int unorderedSeatCount = 0;
  int totalSeatCount = 0;
  int unorderedMeetingRoomCount = 0;
  int totalMeetingRoomCount = 0;

  @override
  void initState() {
    super.initState();

    this.getData();
  }

  Future<void> getData() async {
    // get stores
    await context.read<Stores>().getStores();
    // get store id
    setState(() {
      this.storeId = context.read<Stores>().storeId;
    });

    getMainAnnouncements();
    getAdvertisements();

    await context.read<Products>().getProducts(this.storeId);
    await context
        .read<Products>()
        .findOrderedProducts(this.storeId, DateTime.now(), DateTime.now());

    setState(() {
      this.totalSeatCount = context.read<Products>().seatList.length;
      this.unorderedSeatCount = context.read<Products>().getUnorderedSeatCount();
      this.totalMeetingRoomCount = context.read<Products>().meetingRoomList.length;
      this.unorderedMeetingRoomCount = context.read<Products>().getUnorderedMeetingRoomCount();
    });
  }

  Future<void> getMainAnnouncements() async {
    var url = Uri.parse(serverUrl + '/api/announcement/list');
    var body = jsonEncode({"key": "", "offset": 0, "pagesize": pageSizeLimit, "type": 0});

    var response = await http.post(url, body: body, headers: {"Content-Type": "application/json"});
    var responseBody = jsonDecode(response.body);

    List<Object> ans = responseBody['data'];
    List<Announcement> finalMainAnnoList = [];

    ans.forEach((element) {
      Map<String, Object> an = element;
      finalMainAnnoList.add(Announcement.fromJson(an));
    });

    setState(() {
      this.mainAnnoList = finalMainAnnoList;
    });
  }

  Future<void> getAdvertisements() async {
    var url = Uri.parse(serverUrl + '/api/advertising/list');
    var body = jsonEncode({"key": "", "offset": 0, "pagesize": pageSizeLimit});

    var response = await http.post(url, body: body, headers: {"Content-Type": "application/json"});
    var responseBody = jsonDecode(response.body);

    List<Object> jsonObjList = responseBody['data'];
    List<Advertisement> finalAds = [];

    jsonObjList.forEach((element) {
      Map<String, Object> jsonObject = element;
      finalAds.add(Advertisement.fromJson(jsonObject));
    });

    // precache advertisement images
    /*finalAds.forEach((ad) {
      precacheImage(NetworkImage(ad.imageUrl), context);
    });*/

    setState(() {
      this.advertisementList = finalAds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: backColor,
            child: Column(children: [
              ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                  /*decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0))),*/
                  child: ImageSlideshow(
                    width: double.infinity,
                    height: 200,
                    initialPage: 0,
                    indicatorColor: Color(0xffffff00),
                    indicatorBackgroundColor: Color(0x80ffff00),
                    children: this.advertisementList.map((ad) {
                      return ClipRRect(
                          /*borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0)),*/
                          child: Image.network(
                        ad.imageUrl,
                        fit: BoxFit.cover,
                      ));
                    }).toList(),
                    autoPlayInterval: 5000,
                  )),
              Container(height: 20.0),
              Container(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            SvgPicture.asset('assets/icons/location.svg'),
                            //Icon(Icons.location_on_outlined),
                            Container(width: 10.0),
                            Text(this.storeName /* + ' / 2km'*/)
                          ],
                        ),
                      ),
                      /*TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(StoreSelectionScreen.routeName);
                          },
                          child: Container(
                              child: Row(children: [
                            Text(lang.moreStores[lang.langMode],
                                style: TextStyle(color: Colors.black)),
                            Container(width: 5.0),
                            Icon(Icons.arrow_forward_ios_outlined,
                                size: 18.0, color: Colors.black),
                          ])))*/
                      /*GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(StoreSelectionScreen.routeName);
                          },
                          child: Container(
                              child: Row(children: [
                            Text(lang.moreStores[lang.langMode]),
                            Container(width: 5.0),
                            Icon(Icons.arrow_forward_ios_outlined, size: 18.0),
                          ])))*/
                    ],
                  )),
              Container(height: 20.0),
              Container(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 1,
                          child:
                              /*Ink(
                              width: double.infinity,
                              height: 100.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                      image:
                                          AssetImage('assets/images/store.png'),
                                      fit: BoxFit.cover)),
                              child: InkWell(
                                  onTap: () {
                                    if (Provider.of<Stores>(context,
                                                listen: false)
                                            .storeId ==
                                        -1) {
                                      return;
                                    }
                                    Navigator.of(context)
                                        .pushNamed(OrderScreen.routeName);
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('20 / 80',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          Text(lang.store[lang.langMode],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      ))))*/
                              GestureDetector(
                                  onTap: () {
                                    if (Provider.of<Stores>(context, listen: false).storeId == -1) {
                                      return;
                                    }

                                    print('token: ' + context.read<User>().token);
                                    if (context.read<User>().token == '') {
                                      Navigator.of(context).pushNamed(SignInScreen.routeName);
                                      return;
                                    }

                                    Navigator.of(context).pushNamed(OrderScreen.routeName,
                                        arguments: {'roomType': 0});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    height: 100.0,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                            this.unorderedSeatCount.toString().padLeft(2, '0') +
                                                ' / ' +
                                                this.totalSeatCount.toString().padLeft(2, '0'),
                                            style: TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.bold)),
                                        Text(lang.store[lang.langMode],
                                            style: TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.bold))
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        image: DecorationImage(
                                            image: AssetImage('assets/images/meeting_room.png'),
                                            fit: BoxFit.cover)),
                                  ))),
                      Container(
                        width: 20.0,
                      ),
                      Expanded(
                          flex: 1,
                          child: GestureDetector(
                              onTap: () {
                                if (context.read<Stores>().storeId == -1) {
                                  return;
                                }

                                if (context.read<User>().token == '') {
                                  Navigator.of(context).pushNamed(SignInScreen.routeName);
                                  return;
                                }

                                Navigator.of(context)
                                    .pushNamed(OrderScreen.routeName, arguments: {'roomType': 1});
                              },
                              child: Container(
                                padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
                                height: 100.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                        this.unorderedMeetingRoomCount.toString().padLeft(2, '0') +
                                            ' / ' +
                                            this.totalMeetingRoomCount.toString().padLeft(2, '0'),
                                        style: TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold)),
                                    Text(lang.meetingRoom[lang.langMode],
                                        style: TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold))
                                  ],
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                        image: AssetImage('assets/images/store.png'),
                                        fit: BoxFit.cover)),
                              ))),
                    ],
                  )),
              Container(height: 20.0),
              Expanded(
                  child: SingleChildScrollView(
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
                          margin: EdgeInsets.only(top: 20.0),
                          child: Column(
                              children: this
                                  .mainAnnoList
                                  .map((e) => Container(
                                      margin: EdgeInsets.only(bottom: 20.0),
                                      child: AnnouncementCard(cardData: e)))
                                  .toList())))),
            ])));
  }
}
