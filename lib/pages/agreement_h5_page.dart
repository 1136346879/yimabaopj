import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yimareport/config/project_style.dart';

class AgreementH5Page extends StatefulWidget {
  final int index;
  @override
  _AgreementH5PageState createState() => _AgreementH5PageState();
  AgreementH5Page({Key? key, required this.index}): super(key: key);
}

class _AgreementH5PageState extends State<AgreementH5Page> {
  late WebViewController _webViewController;
  late String filePath;

  @override
  void initState() {
    super.initState();
    filePath = widget.index == 0 ? 'https://yimabao.cn/readtemplate/user-agreement' : 'https://yimabao.cn/readtemplate/privacy-policy';
  }

  _loadHtmlFromAssets() async {
    _webViewController.loadUrl(filePath);
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == 0 ? "用户协议" : "隐私协议"),
        brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: PS.backgroundColor,
      ),
      body: Container(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
            _loadHtmlFromAssets();
          },
        ),
      ),
    );
  }
}

