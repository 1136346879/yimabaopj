import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/pages/agreement_page.dart';

import 'config/project_config.dart';
import 'pages/loading_page.dart';
import 'utils/my_router.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver();

Future<void> main() async {
  // initializeDateFormatting().then((_) => runApp(MyApp()));
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // await SentryFlutter.init(
  //       (options) {
  //     options.dsn = 'https://a02ddcca9b6a463b9b9d212847d9b4af@o1254437.ingest.sentry.io/6422337';
  //     // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
  //     // We recommend adjusting this value in production.
  //     options.tracesSampleRate = 1.0;
  //   },
  //   appRunner: () => runApp(
  //     EasyLocalization(
  //         supportedLocales: [Locale('zh')],
  //         path: 'assets/translations', // <-- change the path of the translation files
  //         fallbackLocale: Locale('zh'),
  //         child: MyApp()
  //     ),
  //   ),
  // );
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool hasAgree = sharedPreferences.getBool(ProjectConfig.agreementKey) ?? false;
  runApp(
    EasyLocalization(
        supportedLocales: [Locale('zh')],
        path: 'assets/translations', // <-- change the path of the translation files
        fallbackLocale: Locale('zh'),
          child: MyApp(isAgree: hasAgree)
    ),
  );

  // if(Platform.isAndroid){ // 设置状态栏背景及颜色
  //   SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  //   // SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  //   // SystemChrome.setEnabledSystemUIOverlays([]); //隐藏状态栏
  // }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final bool isAgree;
  MyApp({Key? key, required this.isAgree}): super(key: key);
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
        primaryColor: Colors.redAccent,
        // appBarTheme: AppBarTheme(
        //   backgroundColor: Colors.white,
        //     titleTextStyle: TextStyle(color: PS.c353535)
        // )
      ),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child!,
        );
      },

      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: isAgree ? LoadingPage() : AgreementPage(),
      // home: NewHome(),
      navigatorObservers: [routeObserver],
    );
  }
}
