import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yimabao/config/project_style.dart';

class MemberPage extends StatefulWidget {
  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  // late WebViewController _webViewController;
  late String filePath;
  GlobalKey rootWidgetKey = GlobalKey();
  var hasNet = false;
  Uint8List? imgStr;
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    filePath = 'https://yimabao.cn/site/vip-info';
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        hasNet = true;
      }
      // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      // imgStr = sharedPreferences.getString("CACHEMEMBERIMG") ?? "";
      imgStr = await _getFromSdcard("CACHEMEMBERIMG");
      setState(() {

      });
    });
  }
  //
  // _loadHtmlFromAssets() async {
  //   _webViewController.loadUrl(filePath);
  // }

  void _saveToImage(Uint8List mUint8List,String name) async  {
    Directory dir = await getTemporaryDirectory();
    String path = dir.path +"/"+name;
    var file = File(path);
    bool exist =  await file.exists();
    print("path =${path}");
    File(path).writeAsBytesSync(mUint8List);
  }
  _getFromSdcard(String name) async{
    Directory dir = await getTemporaryDirectory();
    String path = dir.path +"/"+name;
    var file = File(path);
    bool exist =  await file.exists();
    if(exist){
      final Uint8List bytes = await file.readAsBytes();
      print("找到了${bytes}");
      return bytes;
    }
    return null;
  }

  Uint8List encode(String s) {
    var encodedString = utf8.encode(s);
    var encodedLength = encodedString.length;
    var data = ByteData(encodedLength + 4);
    data.setUint32(0, encodedLength, Endian.big);
    var bytes = data.buffer.asUint8List();
    bytes.setRange(4, encodedLength + 4, encodedString);
    return bytes;
  }

  capturePng() async {
    try {
      // RenderRepaintBoundary boundary =
      // rootWidgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      // var image = await boundary.toImage(pixelRatio: 3.0);
      // ByteData? bytes = await image.toByteData(format: ImageByteFormat.png);
      // Uint8List? pngBytes = bytes?.buffer.asUint8List();
      var bytes = await _webViewController.takeScreenshot();
      _saveToImage(bytes!, "CACHEMEMBERIMG");

      //return
      // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      // sharedPreferences.setString("CACHEMEMBERIMG", String.fromCharCodes(pngBytes!));
      // doingVal = sharedPreferences.getInt(ProjectConfig.doingKey) ?? 7;
    } catch (e) {
      print(e);
    }

  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Widget content() {
      if(hasNet) {
        return InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(filePath)),
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
          },
          onLoadStop: (_c, _url) {
            capturePng();
          },
        );
      }
      if(imgStr != null) {
        return Image.memory(imgStr!, width: double.infinity,);
      }
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("会员"),
        // brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: PS.backgroundColor,
      ),
      body: Container(
        child: RepaintBoundary(key: rootWidgetKey, child: content()),
      ),
    );
  }
}
