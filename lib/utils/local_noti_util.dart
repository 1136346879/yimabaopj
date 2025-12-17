import 'package:dart_date/dart_date.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:yimabao/config/project_config.dart';
import 'package:yimabao/request/mine_api.dart';


class LocalNotiUtil {
  factory LocalNotiUtil() => _getInstance();
  static LocalNotiUtil get instance => _getInstance();
  static LocalNotiUtil? _instance;
  LocalNotiUtil._internal();
  static LocalNotiUtil _getInstance() {
    if (_instance == null) {
      _instance = new LocalNotiUtil._internal();
      tz.initializeTimeZones();
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    }
    return _instance!;
  }
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  load() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    // final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
    // final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  cancelAllNotis() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  resetNotiQueue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(!(sharedPreferences.getBool(ProjectConfig.localNotiKey) ?? true)) return;
    // JPush jpush = new JPush();
    // var fireDate = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 30000);
    // var localNotification = LocalNotification(
    //     id: 234,
    //     title: 'notification title',
    //     buildId: 1,
    //     content: 'notification content',
    //     fireTime: fireDate,
    //     subtitle: 'notification subtitle', // 该参数只有在 iOS 有效
    //     badge: 5, // 该参数只有在 iOS 有效
    // );
    // jpush.sendLocalNotification(localNotification).then((res) { print(res.toString());});

    //先取消之前的通知
    await flutterLocalNotificationsPlugin.cancelAll();
    sharedPreferences.setString("NOTITEST", "");
    //test
    // var detroit1 = tz.getLocation('Asia/Shanghai');
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //     0,
    //     '提醒',
    //     '30s后提示',
    //     tz.TZDateTime.now(detroit1).add(const Duration(seconds: 30)),
    //     // tz.TZDateTime.from(val.values.first, detroit),
    //     const NotificationDetails(
    //         android: AndroidNotificationDetails(
    //           'your channel id', 'your channel name',
    //           channelDescription: 'your channel description', ticker: '提醒',)),
    //     androidAllowWhileIdle: true,
    //
    //     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //     1,
    //     '提醒',
    //     '60s后提示',
    //     tz.TZDateTime.now(detroit1).add(const Duration(seconds: 60)),
    //     // tz.TZDateTime.from(val.values.first, detroit),
    //     const NotificationDetails(
    //         android: AndroidNotificationDetails(
    //           'your channel id', 'your channel name',
    //           channelDescription: 'your channel description', ticker: '提醒',)),
    //     androidAllowWhileIdle: true,
    //
    //     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
    // return;
    var lastRecord = await MineAPI.instance.getLastRecord();
    if(lastRecord == null) return;
    DateTime markDay = dateTimeToYMD(DateUtil.getDateTimeByMs(int.parse(lastRecord["markAt"])));
    var duration = dateTimeToYMD(DateTime.now()).difference(markDay).inDays;
    var isDoing = lastRecord["type"] == 1;
    var doingVal, cycleVal;

    if(MineAPI.instance.getAccount() != null) {
      doingVal = sharedPreferences.getInt(ProjectConfig.doingKey) ?? 7;
      cycleVal = sharedPreferences.getInt(ProjectConfig.cycleKey) ?? 28;
    } else {
      doingVal = sharedPreferences.getInt(ProjectConfig.localDoingKey) ?? 7;
      cycleVal = sharedPreferences.getInt(ProjectConfig.localCycleKey) ?? 28;
    }
    var circle = isDoing ? doingVal : cycleVal;
    var tip = "";
    List<Map<String, DateTime>> all = [];
    if(isDoing) {
      //今天走
      var since0Go = markDay.add(Duration(days: circle - 1)).add(Duration(hours: 8));
      all.add({"姨妈走了吗？记得标记哦~": since0Go});
    } else {
      //距离姨妈开始还有5天
      var since5 = markDay.add(Duration(days: circle - 5)).add(Duration(hours: 8));
      //距离姨妈开始还有3天
      var since3 = markDay.add(Duration(days: circle - 3)).add(Duration(hours: 8));
      //距离姨妈开始还有1天
      var since1 = markDay.add(Duration(days: circle - 1)).add(Duration(hours: 8));
      //距离姨妈开始还有0天
      var since0 = markDay.add(Duration(days: circle)).add(Duration(hours: 8));
      all.add({"距离姨妈开始还有5天。": since5});
      all.add({"距离姨妈开始还有3天。": since3});
      all.add({"预计姨妈明天就要来了。": since1});
      all.add({"今天姨妈来了吗？记得标记哦~": since0});
    }
    var testStr = all.map((e) => {
      e.keys.first, DateUtil.formatDate(e.values.first)
    }).toString();
    sharedPreferences.setString("NOTITEST", testStr);
    all.asMap().entries.forEach((element) async {
      var index = element .key;
      var val = element.value;
      var detroit = tz.getLocation('Asia/Shanghai');
      String tipStr = '${val.keys.first}';
      //   await flutterLocalNotificationsPlugin.zonedSchedule(
      //       index,
      //       '经期提醒',
      //       '${val.keys.first}',
      //       // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 30)),
      //       tz.TZDateTime.from(val.values.first, detroit),
      //       const NotificationDetails(
      //           android: AndroidNotificationDetails(
      //             'your channel id', '提醒',
      //             channelDescription: '', ticker: '经期提醒', priority: Priority.max, importance: Importance.high)),
      //         androidAllowWhileIdle: true,
      //
      //         uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
      // });
    });
    }
  // test() async {
  //   await flutterLocalNotificationsPlugin.cancelAll();
  //   List<Map<String, DateTime>> arr = [
  //     { "1分钟": DateTime.now().add(Duration(minutes: 1))},
  //     { "2分钟": DateTime.now().add(Duration(minutes: 2))},
  //     { "3分钟": DateTime.now().add(Duration(minutes: 3))},
  //     { "5分钟": DateTime.now().add(Duration(minutes: 5))},
  //     { "10分钟": DateTime.now().add(Duration(minutes: 10))},
  //     { "30分钟": DateTime.now().add(Duration(minutes: 30))},
  //     { "1小时": DateTime.now().add(Duration(minutes: 60))},
  //     { "3小时": DateTime.now().add(Duration(minutes: 180))},
  //     { "5小时": DateTime.now().add(Duration(minutes: 300))},
  //   ];
  //
  //   arr.asMap().entries.forEach((element) async {
  //     var index = element .key;
  //     var val = element.value;
  //     var detroit = tz.getLocation('Asia/Shanghai');
  //     await flutterLocalNotificationsPlugin.zonedSchedule(
  //         index + 100,
  //         '姨妈宝测试提醒',
  //         '${val.keys.first}',
  //         // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 30)),
  //         tz.TZDateTime.from(val.values.first, detroit),
  //         const NotificationDetails(
  //             android: AndroidNotificationDetails(
  //               'your channel id', '提醒',
  //               channelDescription: '', ticker: '经期提醒', priority: Priority.max, importance: Importance.high)),
  //           androidAllowWhileIdle: true,
  //
  //           uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  //   });
  // }
  // test2() async {
  //   await flutterLocalNotificationsPlugin.cancelAll();
  //   List<Map<String, DateTime>> arr = [
  //     { "1分钟": DateTime.now().add(Duration(minutes: 1))},
  //     { "2分钟": DateTime.now().add(Duration(minutes: 2))},
  //     { "3分钟": DateTime.now().add(Duration(minutes: 3))},
  //     { "5分钟": DateTime.now().add(Duration(minutes: 5))},
  //     { "10分钟": DateTime.now().add(Duration(minutes: 10))},
  //     { "30分钟": DateTime.now().add(Duration(minutes: 30))},
  //     { "1小时": DateTime.now().add(Duration(minutes: 60))},
  //     { "3小时": DateTime.now().add(Duration(minutes: 180))},
  //     { "5小时": DateTime.now().add(Duration(minutes: 300))},
  //   ];
  //
  //   // arr.asMap().entries.forEach((element) async {
  //   //   var index = element .key;
  //   //   var val = element.value;
  //     var detroit = tz.getLocation('Asia/Shanghai');
  //     await flutterLocalNotificationsPlugin.zonedSchedule(
  //         999,
  //         '姨妈宝测试提醒',
  //         '1分钟',
  //         // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 30)),
  //         tz.TZDateTime.now(detroit).add(Duration(minutes: 1)),
  //         const NotificationDetails(
  //             android: AndroidNotificationDetails(
  //                 'your channel id', 'your channel name',
  //               // '提醒', '',
  //               channelDescription: 'your channel description', ticker: '姨妈宝测试提醒', priority: Priority.max)),
  //         androidAllowWhileIdle: true,
  //
  //
  //         uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  //   // });
  // }
  dateTimeToYMD(DateTime date) {
    return DateUtil.getDateTime(DateUtil.formatDate(date, format: 'yyyy-MM-dd'));
  }

}