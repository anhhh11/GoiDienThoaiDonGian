import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter/services.dart';

class DialPad extends StatefulWidget {
  const DialPad({Key? key}) : super(key: key);

  @override
  _DialPadState createState() => _DialPadState();
}

class _DialPadState extends State<DialPad> {
  String display = '';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    display,
                    textScaleFactor: 1.0,
                    style: const TextStyle(
                        fontSize: 36,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                mainAxisAlignment: MainAxisAlignment.end,
                textBaseline: TextBaseline.ideographic,
                children: [
                  InkWell(
                    onTap: () async {
                      SystemSound.play(SystemSoundType.click);
                      if (display.isNotEmpty) {
                        setState(() {
                          display = display.substring(0, display.length - 1);
                        });
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(
                        Icons.backspace,
                        size: 35,
                        color: Color(0xFFec4055),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
        ),
        Row(
          children: [
            dialPadButton(size, '1'),
            dialPadButton(size, '2'),
            dialPadButton(size, '3')
          ],
        ),
        Row(
          children: [
            dialPadButton(size, '4'),
            dialPadButton(size, '5'),
            dialPadButton(size, '6')
          ],
        ),
        Row(
          children: [
            dialPadButton(size, '7'),
            dialPadButton(size, '8'),
            dialPadButton(size, '9')
          ],
        ),
        Row(
          children: [
            dialPadButton(size, '*', color: const Color(0xFF999999)),
            dialPadButton(size, '0'),
            dialPadButton(size, '#', color: const Color(0xFF999999))
          ],
        ),
        InkWell(
          child: Container(
            height: 80,
            width: double.infinity,
            color: const Color(0xFF4CD04C),
            child: const Center(
              child: Icon(
                Icons.call,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          onTap: () async {
            SystemSound.play(SystemSoundType.click);
            FlutterPhoneDirectCaller.callNumber(display);
          },
        )
      ],
    );
  }

  Widget dialPadButton(Size size, String value, {Color? color}) {
    return InkWell(
      highlightColor: Colors.black45,
      onTap: () async {
        SystemSound.play(SystemSoundType.click);
        setState(() {
          display = display + value;
        });
      },
      child: Container(
        height: size.height * 0.15,
        width: size.width * 0.33,
        decoration:
            BoxDecoration(border: Border.all(color: Colors.grey, width: 0.025)),
        child: Center(
          child: Text(
            value,
            textScaleFactor: 1.0,
            style: TextStyle(
                color: color ?? const Color(0xFF5798e4),
                fontSize: 35,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
