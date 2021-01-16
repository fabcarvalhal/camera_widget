import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:camera_widget/camera_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String currentCode = "No Code";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: Stack(
            fit: StackFit.loose,
            children: [
              MyCameraWidget(
                onCodeRead: readCode,
              ),
              Container(
                height: 50,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void readCode(String value) {
    setState(() {
      currentCode = value;
    });
  }
}
