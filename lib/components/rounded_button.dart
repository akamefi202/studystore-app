import 'package:flutter/material.dart';
import 'package:studystore_app/constants/colors.dart';

class RoundedButton extends StatefulWidget {
  final String title;
  final int type; // 0: big button, 1: middle button, 2: small button
  final Function onPressed;
  final bool disabled;

  RoundedButton({Key key, this.title, this.onPressed, this.type, this.disabled = false})
      : super(key: key);
  @override
  _RoundedButtonState createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  @override
  void initState() {
    super.initState();
  }

  Widget getInkWell() {
    return InkWell(
      onTap: widget.disabled ? () {} : widget.onPressed as Function(),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: widget.type == 0 || widget.type == 1
            ? const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 10.0, right: 10.0)
            : const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
        child: Center(
          child: Text(widget.title,
              style: TextStyle(color: widget.disabled ? Color(0xff808080) : Colors.black)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);

    return Material(
        color: Colors.transparent,
        child: widget.type == 0 || widget.type == 1
            ? Ink(
                width: widget.type == 0 ? data.size.width * 0.5 : 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: widget.disabled ? Color(0xffc0c0c0) : Color(0xfff2f2f2)),
                child: this.getInkWell())
            : Ink(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: widget.disabled ? Color(0xffc0c0c0) : Color(0xfff2f2f2)),
                child: this.getInkWell()));
  }
}
