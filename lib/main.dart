import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimabao/pages/agreement_page.dart';
import 'package:yimabao/pages/new_home.dart';

import 'config/project_config.dart';
import 'pages/loading_page.dart';
import 'utils/my_router.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver();

Future<void> main() async {
  print('=======进入main1');
  // initializeDateFormatting().then((_) => runApp(MyApp()));
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool hasAgree = sharedPreferences.getBool(ProjectConfig.agreementKey) ?? false;
  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://a02ddcca9b6a463b9b9d212847d9b4af@o1254437.ingest.sentry.io/6422337';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      EasyLocalization(
          supportedLocales: [Locale('zh')],
          path: 'assets/translations', // <-- change the path of the translation files
          fallbackLocale: Locale('zh'),
          child: MyApp(isAgree: hasAgree)
      ),
    ),
  );
  // runApp(
  //   EasyLocalization(
  //       supportedLocales: [Locale('zh')],
  //       path: 'assets/translations', // <-- change the path of the translation files
  //       fallbackLocale: Locale('zh'),
  //         child: MyApp(isAgree: hasAgree)
  //   ),
  // );
LogUtil.d('=======进入main2');
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
      title: '姨妈宝',
      navigatorKey: MyRouter.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.redAccent,
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
      home:  LoadingPage(isOnlyUnionad: !isAgree,),
      // home: NewHome(),
      navigatorObservers: [routeObserver],
    );
  }
}
