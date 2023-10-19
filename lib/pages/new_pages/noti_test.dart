import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimabao/config/project_style.dart';

class NotiTest extends StatefulWidget {
  @override
  _NotiTestState createState() => _NotiTestState();
}

class _NotiTestState extends State<NotiTest> {
  String result = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      result = sharedPreferences.getString("NOTITEST") ?? "";
      setState(() {

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("通知测试"),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: PS.c353535),
      body: Container(
        child: Center(
          child: Text(result),
        ),
      ),
    );
  }
}
