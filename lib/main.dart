import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yimareport/pages/new_home.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pages/loading_page.dart';
import 'utils/my_router.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver();

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
  // runApp(MyApp());
  // if(Platform.isAndroid){ // 设置状态栏背景及颜色
  //   SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  //   // SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  //   // SystemChrome.setEnabledSystemUIOverlays([]); //隐藏状态栏
  // }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: MyRouter.navigatorKey,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        // brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      // home: LoadingPage(),
      home: NewHome(),
      navigatorObservers: [routeObserver],
    );
  }
}
