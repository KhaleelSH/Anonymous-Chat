import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final String title;
  final Function onTap;
  final Color backgroundColor;
  final Color textColor;
  final double font;

  MyButton({
    @required this.title,
    @required this.onTap,
    @required this.backgroundColor,
    @required this.textColor,
    @required this.font,
  });

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _isProcessing;
  String title;

  @override
  void initState() {
    super.initState();
    _isProcessing = false;
    title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5.0),
        child: InkWell(
          onTap: () {
            if (_isProcessing) return;
            setState(() {
              _isProcessing = true;
            });
            () async {
              await widget.onTap();
              setState(() {
                _isProcessing = false;
              });
            }();
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: !_isProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 16.0),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.textColor,
                          fontSize: widget.font,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(widget.textColor)),
                  ),
          ),
        ),
      ),
    );
  }
}
