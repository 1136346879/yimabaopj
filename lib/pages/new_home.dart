import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yimabao/api/db_api.dart';
import 'package:yimabao/config/project_config.dart';
import 'package:yimabao/config/project_style.dart';
import 'package:yimabao/db/entities/local_record.dart';
import 'package:yimabao/db/entities/mark.dart';
import 'package:yimabao/db/entities/member_record.dart';
import 'package:yimabao/request/mark_api.dart';
import 'package:yimabao/request/mine_api.dart';
import 'package:yimabao/utils/event_bus_util.dart';
import 'package:yimabao/utils/event_util.dart';
import 'package:yimabao/utils/local_noti_util.dart';
import 'package:yimabao/utils/show_data_util.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


import '../main.dart';
import 'new_pages/add_diary_page.dart';

class NewHome extends StatefulWidget {
  @override
  _NewHomeState createState() => _NewHomeState();
}

class _NewHomeState extends State<NewHome> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin implements RouteAware {
  late final ValueNotifier<ShowDataEntry> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late int doingVal = 7;
  late int cycleVal = 28;
  List<dynamic>? _recordDataSource;
  HashMap<String, List<Mark>>? _markDataSource;
  var _lastRecord;
  List<List<DateTime>>? _recordDateSections;//姨妈标记所有时间区间
  HashMap<String, ShowDataEntry>? dataSource;
  String tip = "";
  var netSubscription;
  var isFirstLoad = true;
  StreamSubscription? _tabChangeSubscription;
  var lastPopTime;
  DateTime _now = DateTime.now();
  int selectedRating = 0;//疼痛
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _focusedDay = getNowDate();
    _tabChangeSubscription = eventBus.on<TabChangeEvent>().listen((event) async {
      await getCycle();
      init();
      // c();
    });
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await getCycle();
      init();
      await MineAPI.instance.memberSyncCircle();
      await MineAPI.instance.memberSyncData();
      await MarkAPI.instance.markSyncData();
      init();
      // pushTest();
    });
    WidgetsBinding.instance?.addObserver(this);
    netSubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      if(result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        if(isFirstLoad) {
          isFirstLoad = false;
          return;
        }
        //监听网络变化
        await MarkAPI.instance.markSyncData();
        await MineAPI.instance.memberSyncData();
        init();
      }
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }
  //同步数据
  // firstLoad() async {
  //   await MineAPI.instance.memberSyncData();
  //   await MarkAPI.instance.markSyncData();
  //   setState(() {});
  // }
  //推送测试
  pushTest() async {
    // LocalNotiUtil.instance.resetNotiQueue();
    // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
//     const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
//     final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
//     final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//
//
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//         0,
//         'scheduled title',
//         'scheduled body',
//         tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
//         const NotificationDetails(
//             android: AndroidNotificationDetails(
//                 'your channel id', 'your channel name',
//                 channelDescription: 'your channel description')),
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime);
//     await flutterLocalNotificationsPlugin.cancelAll();
    return;

    // final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('your channel id', 'your channel name',
    //     channelDescription: 'your channel description',
    //     importance: Importance.max,
    //     priority: Priority.high,
    //     ticker: 'ticker',
    //     timeoutAfter: 10000,
    //     // when: DateTime.now().add(Duration(seconds: 10)).millisecond
    // );
    // final NotificationDetails platformChannelSpecifics =
    // NotificationDetails(android: androidPlatformChannelSpecifics);
    // await flutterLocalNotificationsPlugin.show(
    //     0, 'plain title', 'plain body', platformChannelSpecifics,
    //     payload: 'item x');

  }
  init() async {
    await autoAddRecord();
    //所有的姨妈记录
    _recordDataSource = await MineAPI.instance.getAllRecord();
    //所有的标记数据
    _markDataSource = await getAllMarks();
    //最后一次标记
    _lastRecord = await MineAPI.instance.getLastRecord();
    _recordDateSections = await getAllRecordsDateSection();
    await buildDataSource();
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
    setState(() {});
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
    if(state == AppLifecycleState.paused) {
      print('APP进入后台');
    } else  if (state == AppLifecycleState.resumed) {
      print('APP进入前台');
      if(MineAPI.instance.getAccount() == null) {
        init();
        return;
      };
      await getCycle();
      await MineAPI.instance.memberSyncData();
      await MarkAPI.instance.markSyncData();
      init();

    } else  if (state == AppLifecycleState.inactive) {
      print('APP进入xx');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    netSubscription.cancel();
    routeObserver.unsubscribe(this);
    _tabChangeSubscription?.cancel();
    super.dispose();
  }

  ShowDataEntry _getEventsForDay(DateTime day) {
    // Implementation example
    // return kEvents[day] ?? [];
    var data = dataSource?[DateUtil.formatDate(day, format: 'yyyy-MM-dd')] ?? ShowDataEntry();
    return data;
  }


  void _onClickItem(var data, var selectData, {String? label, Mark? editItem}) {
    Pickers.showSinglePicker(
      context,
      data: data,
      selectData: selectData,
      pickerStyle: DefaultPickerStyle(),
      suffix: label,
      onConfirm: (p, position) async {
        print('longer >>> 返回数据下标：$position');
        print('longer >>> 返回数据：$p');
        print('longer >>> 返回数据类型：${p.runtimeType}');

        if(label == 'KG') {
          //体重
          if(editItem == null) {
            Mark mark = Mark(null, "weight", "${getNowDate().microsecondsSinceEpoch}", "${_selectedDay?.millisecondsSinceEpoch}", weight: p);
            await MarkAPI.instance.insertMark(mark);
            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
            sharedPreferences.setString("LASTWEIGHT", p);
          } else {
            if(p == '--') {
              await MarkAPI.instance.delete(editItem);
            } else {
              editItem.weight = p;
              await MarkAPI.instance.updateMark(editItem);
            }
          }
        } else if(label == '℃') {
          if(editItem == null) {
            Mark mark = Mark(null, "temperature", "${getNowDate().microsecondsSinceEpoch}", "${_selectedDay?.millisecondsSinceEpoch}", temperature: p);
            await MarkAPI.instance.insertMark(mark);
          } else {
            if(p == '--') {
              await MarkAPI.instance.delete(editItem);
            } else {
              editItem.temperature = p;
              await MarkAPI.instance.updateMark(editItem);
            }
          }
        } else {//睡眠
          if(editItem == null) {
            Mark mark = Mark(null, "sleep", "${getNowDate().microsecondsSinceEpoch}", "${_selectedDay?.millisecondsSinceEpoch}", length: p);
            await MarkAPI.instance.insertMark(mark);
          } else {
            if(p == '--') {
              await MarkAPI.instance.delete(editItem);
            } else {
              editItem.length = p;
              await MarkAPI.instance.updateMark(editItem);
            }
          }
        }
        init();
        // setState(() {
          // if (data == PickerDataType.sex) {
          //   selectSex = p;
          // } else if (data == PickerDataType.education) {
          //   selectEdu = p;
          // } else if (data == PickerDataType.subject) {
          //   selectSubject = p;
          // } else if (data == PickerDataType.constellation) {
          //   selectConstellation = p;
          // } else if (data == PickerDataType.zodiac) {
          //   selectZodiac = p;
          // } else if (data == PickerDataType.ethnicity) {
          //   selectEthnicity = p;
          // }
        // });
      },
    );
  }
  getNowDate() {
    String ymd = DateUtil.formatDate(DateTime.now(), format: "yyyy-MM-dd");
    String hms = DateUtil.formatDate(DateTime.now(), format: "HH:mm:ss");
    DateTime? time = DateUtil.getDateTime("${ymd} ${hms}");
    // DateTime.now() = date.month;
    return time!;
    // return _now;
    // return DateTime.now();
  }
  Future<void> _selectDate() async {
    // return;
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _now,
      firstDate: _now.subtract(Duration(days: 210)),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    String ymd = DateUtil.formatDate(date, format: "yyyy-MM-dd");
    String hms = DateUtil.formatDate(DateTime.now(), format: "HH:mm:ss");
    DateTime? time = DateUtil.getDateTime("${ymd} ${hms}");
    // DateTime.now() = date.month;
    _now = time!;
    ProjectConfig.now = _now;
    setState(() {

    });
    init();
  }
  dateTimeToYMD(DateTime date) {
    return DateUtil.getDateTime(DateUtil.formatDate(date, format: 'yyyy-MM-dd'));
  }
  getCycle() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(MineAPI.instance.getAccount() != null) {
      doingVal = sharedPreferences.getInt(ProjectConfig.doingKey) ?? 7;
      cycleVal = sharedPreferences.getInt(ProjectConfig.cycleKey) ?? 28;
    } else {
      doingVal = sharedPreferences.getInt(ProjectConfig.localDoingKey) ?? 7;
      cycleVal = sharedPreferences.getInt(ProjectConfig.localCycleKey) ?? 28;
    }

    setState(() {});
  }
  //自动标记姨妈来了 走了。
  autoAddRecord() async {
    tip = "";
    var lastRecord = await MineAPI.instance.getLastRecord();
    //如果经期 > 设定值+2 自动标记经期结束, 日期为标定日期
    if(lastRecord != null) {
      //判断
      var duration = dateTimeToYMD(getNowDate()).difference(dateTimeToYMD(DateUtil.getDateTimeByMs(int.parse(lastRecord["markAt"])))).inDays;
      var isDoing = lastRecord["type"] == 1;
      var circle = isDoing ? doingVal : cycleVal;
      if(isDoing) {
        // if(duration < circle) {
        //   tip = "${circle - duration}天后结束";
        // } else if (duration == circle) {
        //   tip = "今天结束";
        // }
        // else if (duration > circle) {
        //   tip = "多了${duration - circle}天";
        // }
        tip = "月经第${duration + 1}天";
      } else {
        if(duration < circle) {
          // tip = "${circle - duration}天后来";
          tip = "距离经期还有${circle - duration}天";
        }
        else if (duration == circle) {
          tip = "今天来";
        }
        else if (duration > circle && duration <= circle * 2) {
          tip = "晚了${duration - circle}天";
        }
        else if (duration > circle * 2) {
          tip = "建议就医";
        }
      }
      if(isDoing) {
        if (duration > 14 ) {
          var record = LocalRecord(
              null,
              "${DateUtil.getDateTimeByMs(int.parse(lastRecord["markAt"])).add(Duration(days: circle - 1)).millisecondsSinceEpoch}",
              "${getNowDate().millisecondsSinceEpoch}",
              2
          );
          await MineAPI.instance.insertRecord(record, buildContext: context);
        }
      }
    }
  }
  //获取所有的姨妈标记数据时间区间
  getAllRecordsDateSection() {
    List<List<DateTime>> result = [];
    List<DateTime> tempItem = [];
    _recordDataSource?.asMap().forEach((index, element) {
      tempItem.add(DateUtil.getDateTimeByMs(int.parse(element["markAt"])));
      if(tempItem.length == 2) {
        result.add(tempItem);
        tempItem = [];
      }
    });
    if(tempItem.length > 0) {
      tempItem.add(getNowDate());
      result.add(tempItem);
    }
    return result;
  }

  getAllMarks() async {
    List<Mark> allMarks = await MarkAPI.instance.allMarks();
    // await DBAPI.sharedInstance.markDao.findMarks();
    HashMap<String, List<Mark>> result = HashMap();
    for(int i = 0; i < allMarks.length; i++) {
      Mark item = allMarks[i];
      var dateStr = DateUtil.formatDateMs(int.parse(item.dayAt), format: 'yyyy-MM-dd');
      if(result[dateStr] == null) {
        result[dateStr] = [item];
      } else {
        result[dateStr]?.add(item);
      }
    }
    return result;
  }
  //事件数据源
  buildDataSource() async {
    //获取所有事件的时间区间TODO
    HashSet<String> allDaySet = HashSet();
    (_recordDataSource ?? []).forEach((e) {
      var tDate = DateUtil.getDateTimeByMs(int.parse(e['markAt']));
      var tDateStr = DateUtil.formatDate(tDate, format: 'yyyy-MM-dd');
      allDaySet.add(tDateStr);
    });
    allDaySet.addAll((_markDataSource ?? HashMap<String, List<Mark>>()).keys);
    var allDays = allDaySet.toList().map((e) => DateUtil.getDateTime(e)).toList();
    // daysInRange(DateUtil.getDateTimeByMs(int.parse(_recordDataSource?.first["markAt"])), DateTime.now().add(Duration(days: 1)));
    var tempRecordDataSource = List.from(_recordDataSource ?? []);
    //构件数据源
    var _dataSource = HashMap<String, ShowDataEntry>();
    allDays.forEach((e) {
      String dateStr = DateUtil.formatDate(e, format: 'yyyy-MM-dd');
      var obj = ShowDataEntry();
      //遍历姨妈事件
      for (int i = 0; i < tempRecordDataSource.length; i++) {
        var t = tempRecordDataSource[i];
        var tDate = DateUtil.getDateTimeByMs(int.parse(t['markAt']));
        var tDateStr = DateUtil.formatDate(tDate, format: 'yyyy-MM-dd');
        if(dateStr == tDateStr) {//找到了
          obj.recordInfo = t;
          obj.isYMbegin = t['type'] == 1;
          obj.isYNend = t['type'] == 2;
          if(i == tempRecordDataSource.length - 1) {
            obj.isShowYMbegin = t['type'] == 1;
            obj.isShowYNend = t['type'] == 2;
          }
          //移除当前item
          tempRecordDataSource.remove(t);
          break;
        }
        //时间比对，停止循环
        if(tDate.isAfter(e!)) break;
      }
      obj.marks =_markDataSource?[dateStr];
      // _markDataSource
      _dataSource[dateStr] = obj;

    });
    dataSource = _dataSource;
  }
  //标记姨妈来了
  addRecord() async {
    var lastRecord = await MineAPI.instance.getLastRecord();
    var account = MineAPI.instance.getAccount();
    if(account != null) {
      var record = MemberRecord(
          null,
          "${_selectedDay!.millisecondsSinceEpoch}",
          "${getNowDate().millisecondsSinceEpoch}",
          lastRecord == null ? 1 : lastRecord["type"] == 1 ? 2 : 1,
          account.user_id!
      );
      await MineAPI.instance.insertRecord(record);
    } else {
      var record = LocalRecord(
          null,
          "${_selectedDay!.millisecondsSinceEpoch}",
          "${getNowDate().millisecondsSinceEpoch}",
          lastRecord == null ? 1 : lastRecord["type"] == 1 ? 2 : 1
      );
      await MineAPI.instance.insertRecord(record);
    }
    //刷新TODO
    // refreshRecord();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
          leadingWidth: 170,
          brightness: Brightness.dark,
          elevation: 0,
          backgroundColor: PS.backgroundColor,
          leading: GestureDetector(onTap: _selectDate, child: Center(child: Row(
            children: [
              SizedBox(width: 10,),
              Text("${DateUtil.formatDate(getNowDate(),format: "MM.dd")} ${DateUtil.getWeekday(getNowDate(), languageCode: "zh", short: true)}", style: PS.smallTextStyle(color: PS.secondTextColor)),
            ],
          ))),
          // leading: GestureDetector(onTap: _selectDate, child: Center(child: Row(
          //   children: [
          //     SizedBox(width: 10,),
          //     Text("${DateUtil.formatDate(getNowDate(),format: "MM.dd")} ${DateUtil.getWeekday(getNowDate(), languageCode: "zh", short: true)}", style: PS.smallTextStyle(color: PS.secondTextColor)),
          //   ],
          // ))),
          // actions: [
          //   Center(child: GestureDetector(
          //       behavior: HitTestBehavior.opaque,
          //       onTap: () async {
          //         await Navigator.push(context, MaterialPageRoute(builder: (_) {
          //           return RecordPage();
          //         }));
          //         refreshRecord();
          //         getCycle();
          //       },
          //       child: Icon(Icons.settings, size: 32,),
          //   )),
          //   SizedBox(width: 10,)
          // ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          // 点击返回键的操作
          if(lastPopTime == null || DateTime.now().difference(lastPopTime) > Duration(seconds: 2)){
            lastPopTime = DateTime.now();
            Fluttertoast.showToast(msg: '再划一次退出！');
          }else{
            lastPopTime = DateTime.now();
            // 退出app
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
          return false;
        },
        child: Container(
          color: PS.backgroundColor,
          child: ListView(
            children: [
              Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TableCalendar(
                    availableGestures: AvailableGestures.horizontalSwipe,
                    daysOfWeekHeight: 23.0,
                    firstDay: DateTime.utc(2021, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    // headerVisible: false,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    locale: 'zh_CN',
                    calendarFormat: _calendarFormat,
                    headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        headerPadding: EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                        headerMargin: EdgeInsets.only(bottom: 5),
                        leftChevronPadding: const EdgeInsets.all(3.0),
                        rightChevronPadding: const EdgeInsets.all(3.0),
                        leftChevronIcon: const Icon(Icons.chevron_left, color: PS.c353535,),
                        rightChevronIcon: const Icon(Icons.chevron_right, color: PS.c353535,),
                        decoration: BoxDecoration(
                            color: PS.backgroundColor
                        )
                    ),
                    availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                    calendarStyle: CalendarStyle(
                      cellMargin: EdgeInsets.fromLTRB(1,3,1,1),
                      isTodayHighlighted: false,

                      // todayDecoration: BoxDecoration(shape: BoxShape.rectangle),
                      // holidayDecoration: BoxDecoration(shape: BoxShape.rectangle,),
                      // selectedDecoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: Colors.redAccent, width: 1), borderRadius: BorderRadius.all(Radius.circular(8)), shape: BoxShape.rectangle,),
                      selectedTextStyle: TextStyle(color: Colors.black),
                      defaultDecoration: BoxDecoration(),
                      weekendDecoration: BoxDecoration(),
                    ),
                    calendarBuilders: CalendarBuilders(
                      outsideBuilder: (context, day, focusedDay) {
                        return SizedBox();
                      },
                      defaultBuilder: (context, day, focusedDay) {
                        var text = DateFormat.d('en').format(day);
                        var _convertDay = DateUtil.formatDate(day, format: 'yyyy-MM-dd');
                        //是否在经期内
                        var isDoing = (_recordDateSections ?? []).where((element) {
                          DateTime? start = DateUtil.getDateTime(DateUtil.formatDate(element[0], format: 'yyyy-MM-dd'));
                          DateTime? end = DateUtil.getDateTime(DateUtil.formatDate(element[1], format: 'yyyy-MM-dd'));
                          return (day.isAfter(start!) || isSameDay(start, day)) && (day.isBefore(end!) || isSameDay(end, day));
                        }).toList().length > 0;
                        var isAfterToday = day.isAfter(getNowDate());
                        //marks
                        List<Mark>? marks = dataSource?[_convertDay]?.marks;
                        //love
                        List<Mark> loves = [];
                        Mark? temperature, weight, diary, sleep, pain, flow;
                        marks?.forEach((element) {
                          if(element.opt == "love") {
                            // if(loves.length < 3) {
                            loves.add(element);
                            // }
                          } else if(element.opt == "temperature") {
                            temperature = element;
                          } else if(element.opt == "weight") {
                            weight = element;
                          } else if(element.opt == "diary") {
                            diary = element;
                          } else if(element.opt == "sleep") {
                            sleep = element;
                          } else if(element.opt == "period_pain") {
                            pain = element;
                          } else if(element.opt == "period_flow") {
                            flow = element;
                          }
                        });
                        //今天标记
                        bool isToday = isSameDay(getNowDate(), day);
                        double tagMargin = Platform.isIOS ? 3 : 3;
                        return Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: isDoing ? Color(0xffFFCCDD) : null,),
                          margin: EdgeInsets.all(1),
                          padding: EdgeInsets.all(1),
                          // child: Center(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.redAccent, width: 1)), child: Text(text))),
                          child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Positioned(child: Center(
                                  child: Row(
                                    children: [
                                      Offstage(
                                        offstage: loves.length > 3,
                                        child: Row(
                                          children: loves.map((e) => Image.asset("images/love.png", width: 10,)).toList(),
                                          mainAxisSize: MainAxisSize.max,
                                        ),
                                      ),
                                      Offstage(
                                        offstage: loves.length <= 3,
                                        child: Row(
                                          children: [
                                            Image.asset("images/love.png", width: 10,),
                                            Text("${loves.length}",style: PS.smallerTextStyle(color: PS.cb2b2b2))
                                          ],
                                          mainAxisSize: MainAxisSize.max,
                                        ),
                                      ),
                                    ],
                                  ),
                                ), bottom: 1,),
                                //体温
                                Positioned(child: Center(
                                  child: Offstage(offstage: temperature == null, child: Text("T", style: PS.smallerTextStyle(color: PS.cb2b2b2),)),
                                ), top: tagMargin,left: tagMargin,),
                                //体重
                                Positioned(child: Center(
                                  child: Offstage(offstage: weight == null, child: Text("H", style: PS.smallerTextStyle(color: PS.cb2b2b2),)),
                                ), top: tagMargin,right: tagMargin,),
                                //日记
                                Positioned(child: Center(
                                  child: Offstage(offstage: !(diary != null || sleep != null), child: Text("D", style: PS.smallerTextStyle(color: PS.cb2b2b2),)),
                                ),right: tagMargin,),
                                //疼痛或流量
                                Positioned(child: Center(
                                  child: Offstage(offstage: !(pain != null || flow != null), child: Text("W", style: PS.smallerTextStyle(color: PS.cb2b2b2),)),
                                ),top: tagMargin,),
                                Center(child: Container(width: 25, height: 20, decoration: isToday ? BoxDecoration(border: Border.all(color: Color(0xFF383838), width: 0.5),borderRadius: BorderRadius.all(Radius.circular(0))) : null, child: Center(child: Text(text, style: PS.normalTextStyle(color: isAfterToday ? Colors.black38 : Color.fromRGBO(35, 35, 35, 1.0)),))))
                              ]
                          ),
                        );
                      },
                      // todayBuilder: (context, day, focusedDay) {
                      //   var text = DateFormat.d().format(day);
                      //   return Container(
                      //     margin: EdgeInsets.all(2),
                      //     child: Center(child: Container(padding: EdgeInsets.all(1), decoration: BoxDecoration(border: Border.all(color: Color(0xFF383838), width: 1), borderRadius: BorderRadius.all(Radius.circular(8))), child: Text(text))),
                      //   );
                      // },
                      // markerBuilder: (context,  day, events) {
                      //   // final isOutside = day.month != _focusedDay.month;
                      //   var isDoing = (_recordDateSections ?? []) .where((element) {
                      //     DateTime start = element[0];
                      //     DateTime end = element[1];
                      //     return day.isAfter(start) && day.isBefore(end) && day.month == start.month && day.month == end.month;
                      //   }).toList().length > 0;
                      //   //标记
                      //   if (isDoing) {
                      //     return Container(
                      //       margin: EdgeInsets.all(2),
                      //       color: Colors.redAccent.withAlpha(50),
                      //     );
                      //   }
                      //   return SizedBox();
                      // },
                      selectedBuilder: (context, day, focusedDay) {
                        var text = DateFormat.d('en').format(day);
                        var _convertDay = DateUtil.formatDate(day, format: 'yyyy-MM-dd');
                        //是否在经期内
                        var isDoing = (_recordDateSections ?? []).where((element) {
                          DateTime? start = DateUtil.getDateTime(DateUtil.formatDate(element[0], format: 'yyyy-MM-dd'));
                          DateTime? end = DateUtil.getDateTime(DateUtil.formatDate(element[1], format: 'yyyy-MM-dd'));
                          return (day.isAfter(start!) || isSameDay(start, day)) && (day.isBefore(end!) || isSameDay(end, day));
                        }).toList().length > 0;
                        var isAfterToday = day.isAfter(getNowDate());
                        //marks
                        List<Mark>? marks = dataSource?[_convertDay]?.marks;
                        //love
                        List<Mark> loves = [];
                        Mark? temperature, weight, diary, sleep, pain, flow;
                        marks?.forEach((element) {
                          if(element.opt == "love") {
                            // if(loves.length < 3) {
                            loves.add(element);
                            // }
                          } else if(element.opt == "temperature") {
                            temperature = element;
                          } else if(element.opt == "weight") {
                            weight = element;
                          } else if(element.opt == "diary") {
                            diary = element;
                          } else if(element.opt == "sleep") {
                            sleep = element;
                          } else if(element.opt == "period_pain") {
                            pain = element;
                          } else if(element.opt == "period_flow") {
                            flow = element;
                          }
                        });
                        //今天标记
                        bool isToday = isSameDay(getNowDate(), day);
                        double tagMargin = Platform.isIOS ? 3 : 3;
                        return Container(
                          margin: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                              color: isDoing ? Color(0xffFFCCDD) : null,
                              border: Border.all(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(6))
                          ),
                          // child: Center(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.redAccent, width: 1)), child: Text(text))),
                          child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Positioned(child: Center(
                                  child: Row(
                                    children: [
                                      Offstage(
                                        offstage: loves.length > 3,
                                        child: Row(
                                          children: loves.map((e) => Image.asset("images/love.png", width: 10,)).toList(),
                                          mainAxisSize: MainAxisSize.max,
                                        ),
                                      ),
                                      Offstage(
                                        offstage: loves.length <= 3,
                                        child: Row(
                                          children: [
                                            Image.asset("images/love.png", width: 10,),
                                            Text("${loves.length}",style: PS.smallerTextStyle(color: PS.cb2b2b2))
                                          ],
                                          mainAxisSize: MainAxisSize.max,
                                        ),
                                      ),
                                    ],
                                  ),
                                ), bottom: 1,),
                                //体温
                                Positioned(child: Center(
                                  child: Offstage(offstage: temperature == null, child: Text("T", style: PS.smallerTextStyle(color: PS.cb2b2b2),)),
                                ), top: tagMargin,left: tagMargin,),
                                //体重
                                Positioned(child: Center(
                                  child: Offstage(offstage: weight == null, child: Text("H", style: PS.smallerTextStyle(color: PS.cb2b2b2),)),
                                ), top: tagMargin,right: tagMargin,),
                                //日记
                                Positioned(child: Center(
                                  child: Offstage(offstage: !(diary != null || sleep != null), child: Text("D", style: PS.smallerTextStyle(color: PS.cb2b2b2),)),
                                ),right: tagMargin,),
                                //疼痛或流量
                                Positioned(child: Center(
                                  child: Offstage(offstage: !(pain != null || flow != null), child: Text("W", style: PS.smallerTextStyle(color: PS.cb2b2b2),)),
                                ),top: tagMargin,),
                                Center(child: Container(width: 25, height: 20, decoration: isToday ? BoxDecoration(border: Border.all(color: Color(0xFF383838), width: 0.5),borderRadius: BorderRadius.all(Radius.circular(0))) : null, child: Center(child: Text(text, style: PS.normalTextStyle(color: isAfterToday ? Colors.black38 : Color.fromRGBO(35, 35, 35, 1.0)),))))
                                // Center(child: Text(text, style: PS.normalTextStyle(color: isAfterToday ? Colors.black38 : Color.fromRGBO(35, 35, 35, 1.0)),))
                              ]
                          ),
                        );
                        //------
                        // var isDoing = (_recordDateSections ?? []).where((element) {
                        //   DateTime? start = DateUtil.getDateTime(DateUtil.formatDate(element[0], format: 'yyyy-MM-dd'));
                        //   DateTime? end = DateUtil.getDateTime(DateUtil.formatDate(element[1], format: 'yyyy-MM-dd'));
                        //   return (day.isAfter(start!) || isSameDay(start, day)) && (day.isBefore(end!) || isSameDay(end, day));
                        // }).toList().length > 0;
                        // var isAfterToday = day.isAfter(DateTime.now());
                        // return Container(
                        //   decoration: BoxDecoration(
                        //       color: isDoing ? Colors.redAccent.withAlpha(50) : null,
                        //       border: Border.all(color: Colors.red, width: 1),
                        //       borderRadius: BorderRadius.all(Radius.circular(6))
                        //   ),
                        //   // child: Center(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.redAccent, width: 1)), child: Text(text))),
                        //   child: Center(child: Text(text, style: PS.normalTextStyle(color: isAfterToday ? Colors.black38 : Color.fromRGBO(35, 35, 35, 1.0)),)),
                        // );
                      },
                      // holidayBuilder: (context, day, focusedDay) {
                      //   return Container(
                      //     decoration: BoxDecoration(
                      //         border: Border.all(color: Colors.red, width: 2),
                      //         borderRadius: BorderRadius.all(Radius.circular(5))
                      //     )
                      //   );
                      // },
                    ),
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                      _selectedEvents.value = _getEventsForDay(selectedDay);
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      // No need to call `setState()` here
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
                const SizedBox(height: 3.0),
                Offstage(
                  offstage: tip == "",
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: PS.marginLarge, vertical: 5),
                    width: double.infinity,
                    color: PS.backgroundColor,
                    child: Text(tip, style: PS.normalTextStyle(color: Color(0xffE8A7AD)),),
                  ),
                ),
                Container(
                  color: PS.backgroundColor,
                  child: ValueListenableBuilder<ShowDataEntry>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      if(dateTimeToYMD(_selectedDay!).isAfter(dateTimeToYMD(getNowDate()))) {
                        return Container(width: double.infinity, height: 200, child: Center(child: Text("期待明天会更好", style: PS.normalTextStyle(),)),);
                      }
                      // return SizedBox();
                      // 能否标记姨妈来了走了

                      //能否标记姨妈来了 走了 逻辑
                      int newTagType = 1;
                      bool isCanTagRecord = false;
                      var tagSwitchValue = false;
                      // if(_lastRecord != null) {
                      //   var lastRecordDate = DateUtil.getDateTimeByMs(int.parse(_lastRecord['markAt']));
                      //   var isDoing = _lastRecord["type"] == 1;
                      //   //4天内的最后一次标记也显示
                      //   if(isSameDay(lastRecordDate, _selectedDay) && dateTimeToYMD(getNowDate()).difference(dateTimeToYMD(lastRecordDate)).inDays <= 3) {
                      //       isCanTagRecord = true;
                      //       newTagType = _lastRecord["type"];
                      //       tagSwitchValue = true;
                      //   } else {//最后一次标记至当前时间的 标记显示
                      //     var duration = dateTimeToYMD(_selectedDay!).difference(dateTimeToYMD(DateUtil.getDateTimeByMs(int.parse(_lastRecord["markAt"])))).inDays + 1;
                      //     if(isDoing) {
                      //       if (duration >= 2) {
                      //         isCanTagRecord = true;
                      //         newTagType = 2;
                      //       }
                      //     } else {
                      //       if(duration >= 15) {
                      //         isCanTagRecord = true;
                      //         newTagType = 1;
                      //       }
                      //     }
                      //   }
                      // } else {
                      //   //3天内可标记 姨妈来了
                      //   if(dateTimeToYMD(getNowDate()).difference(dateTimeToYMD(_selectedDay!)).inDays.abs() <= 2) {
                      //     isCanTagRecord = true;
                      //     tagSwitchValue = false;
                      //   }
                      // }

                      if(_lastRecord != null) {
                        var lastRecordDate = DateUtil.getDateTimeByMs(int.parse(_lastRecord['markAt']));
                        var isDoing = _lastRecord["type"] == 1;
                        //4天内的最后一次标记也显示
                        if(isSameDay(lastRecordDate, _selectedDay) && dateTimeToYMD(getNowDate()).difference(dateTimeToYMD(lastRecordDate)).inDays <= 3) {
                          isCanTagRecord = true;
                          newTagType = _lastRecord["type"];
                          tagSwitchValue = true;
                        } else {//最后一次标记至当前时间的 标记显示
                          var duration = dateTimeToYMD(_selectedDay!).difference(dateTimeToYMD(DateUtil.getDateTimeByMs(int.parse(_lastRecord["markAt"])))).inDays + 1;
                          if(isDoing) {
                            if (duration >= 2 && dateTimeToYMD(getNowDate()).difference(dateTimeToYMD(_selectedDay!)).inDays.abs() <= 2) {
                              isCanTagRecord = true;
                              newTagType = 2;
                            }
                          } else {
                            if(duration >= 15 && dateTimeToYMD(getNowDate()).difference(dateTimeToYMD(_selectedDay!)).inDays.abs() <= 2) {
                              isCanTagRecord = true;
                              newTagType = 1;
                            }
                          }
                        }
                      } else {
                        //3天内可标记 姨妈来了
                        if(dateTimeToYMD(getNowDate()).difference(dateTimeToYMD(_selectedDay!)).inDays.abs() <= 2) {
                          isCanTagRecord = true;
                          tagSwitchValue = false;
                        }
                      }

                      //爱爱记录
                      List<Mark> loves = value.marks?.where((element) => element.opt == "love").toList() ?? [];
                      //体温记录
                      List<Mark> temperatures = value.marks?.where((element) => element.opt == "temperature").toList() ?? [];
                      Mark? temperature = temperatures.length > 0 ? temperatures.first : null;
                      //体重记录
                      List<Mark> weights = value.marks?.where((element) => element.opt == "weight").toList() ?? [];
                      Mark? weight = weights.length > 0 ? weights.first : null;
                      //日记
                      List<Mark> diarys = value.marks?.where((element) => element.opt == "diary").toList() ?? [];
                      Mark? diary = diarys.length > 0 ? diarys.first : null;
                      //疼痛记录
                      List<Mark> pains = value.marks?.where((element) => element.opt == "period_pain").toList() ?? [];
                      Mark? pain = pains.length > 0 ? pains.first : null;
                      //流量记录
                      List<Mark> flows = value.marks?.where((element) => element.opt == "period_flow").toList() ?? [];
                      Mark? flow = flows.length > 0 ? flows.first : null;
                      //是否在经期内, 是否允许标记疼痛记录 流量记录
                      var isDoing = (_recordDateSections ?? []).where((element) {
                        DateTime? start = DateUtil.getDateTime(DateUtil.formatDate(element[0], format: 'yyyy-MM-dd'));
                        DateTime? end = DateUtil.getDateTime(DateUtil.formatDate(element[1], format: 'yyyy-MM-dd'));
                        return (_selectedDay!.isAfter(start!) || isSameDay(start, _selectedDay!)) && (_selectedDay!.isBefore(end!) || isSameDay(end, _selectedDay!));
                      }).toList().length > 0;
                      //睡眠记录
                      List<Mark> sleeps = value.marks?.where((element) => element.opt == "sleep").toList() ?? [];
                      Mark? sleep = sleeps.length > 0 ? sleeps.first : null;
                      return Column(
                        // shrinkWrap: true,
                        children: [
                          //姨妈来了吗？
                          SizedBox(height: 1,),
                          Offstage(
                            offstage: !(isCanTagRecord && newTagType == 1),
                            child: Container(
                              margin: EdgeInsets.symmetric (vertical: 1),
                              padding: EdgeInsets.only(left: 20, right: PS.margin),
                              height: 50,
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("姨妈来了吗？", style: PS.normalTextStyle(),),
                                  FlutterSwitch(
                                    // width: 85.0,
                                    showOnOff: true,
                                    activeColor: Color(0xffE8A7AD),
                                    activeText: " 是",
                                    inactiveText: "否 ",
                                    activeTextColor: Colors.white,
                                    inactiveTextColor: Colors.white,
                                    valueFontSize: 16.0,
                                    value: tagSwitchValue,
                                    onToggle: (bool value) async {
                                      if(value) {
                                        await addRecord();
                                      } else {
                                        await MineAPI.instance.newDeleteRecord(buildContext: context, id: _lastRecord['id']);
                                      }
                                      //重置本地推送你
                                      LocalNotiUtil.instance.resetNotiQueue();
                                      //刷数据
                                      init();
                                    },

                                  ),
                                  // Switch(value: tagSwitchValue, onChanged: (bool value) async {
                                  //   if(value) {
                                  //     await addRecord();
                                  //   } else {
                                  //     await MineAPI.instance.deleteLastRecord(context);
                                  //   }
                                  //   //刷数据
                                  //   init();
                                  // },)
                                ],
                              ),
                            ),
                          ),
                          //姨妈走了吗?
                          Offstage(
                            offstage: !(isCanTagRecord && newTagType == 2),
                            child: Container(
                              margin: EdgeInsets.symmetric (vertical: 1),
                              height: 50,
                              padding: EdgeInsets.only(left: 20, right: PS.margin),
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("姨妈走了吗？", style: PS.normalTextStyle(),),
                                  FlutterSwitch(
                                    // width: 85.0,
                                    showOnOff: true,
                                    activeColor: Color(0xffE8A7AD),
                                    activeTextColor: Colors.white,
                                    inactiveTextColor: Colors.white,
                                    activeText: " 是",
                                    inactiveText: "否 ",
                                    valueFontSize: 15.0,
                                    value: tagSwitchValue,
                                    onToggle: (bool value) async {
                                      if(value) {
                                        await addRecord();
                                      } else {
                                        await MineAPI.instance.newDeleteRecord(buildContext: context, id: _lastRecord['id']);
                                      }
                                      //重置本地推送你
                                      LocalNotiUtil.instance.resetNotiQueue();
                                      //刷数据
                                      init();
                                    },

                                  ),
                                  // Switch(value: tagSwitchValue, onChanged: (bool value) async {
                                  //   if(value) {
                                  //     await addRecord();
                                  //   } else {
                                  //     await MineAPI.instance.deleteLastRecord(context);
                                  //   }
                                  //   //刷数据
                                  //   init();
                                  // },),
                                ],
                              ),
                            ),
                          ),
                          //疼痛
                          Offstage(
                            offstage: !isDoing,
                            child: Container(
                              margin: EdgeInsets.symmetric (vertical: 1),
                              decoration: new BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 50,
                                    padding: EdgeInsets.only(left: 20, right: PS.margin),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("疼痛", style: PS.normalTextStyle(),),
                                        Row(
                                          children: [
                                            Offstage(
                                              offstage: pain == null,
                                              child: RatingBar.builder(
                                                initialRating: double.parse(pain?.level ?? "0"),
                                                direction: Axis.horizontal,
                                                allowHalfRating: false,
                                                itemCount: 5,
                                                itemSize: 26,
                                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                itemBuilder: (context, index) => Text("${index + 1}", style: TextStyle(color: Colors.red, fontWeight: int.parse(pain?.level ?? "0") > index ? FontWeight.w700 : FontWeight.w500, fontSize: 16)),
                                                onRatingUpdate: (rating) async {
                                                  var selectedRating = rating.toInt();
                                                  if(pain?.level == '${selectedRating}') {
                                                    //删除
                                                    await MarkAPI.instance.delete(pain!);
                                                  } else {
                                                    pain?.level = '${selectedRating}';
                                                    await MarkAPI.instance.updateMark(pain);
                                                  }
                                                  init();
                                                },
                                              ),
                                            ),
                                            Offstage(
                                              offstage: pain != null,
                                              child: RatingBar.builder(
                                                initialRating: double.parse(pain?.level ?? "0"),
                                                direction: Axis.horizontal,
                                                allowHalfRating: false,
                                                itemCount: 5,
                                                itemSize: 26,
                                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                itemBuilder: (context, index) => Text("${index + 1}", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 16)),
                                                onRatingUpdate: (rating) async {
                                                  var selectedRating = rating.toInt();
                                                  var painMark = Mark(null, "period_pain", "${getNowDate().microsecondsSinceEpoch}", "${_selectedDay!.millisecondsSinceEpoch}",)..level='${selectedRating}';
                                                  await MarkAPI.instance.insertMark(painMark);
                                                  init();
                                                  print(rating);
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10,)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //流量
                          Offstage(
                            offstage: !isDoing,
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric (vertical: 1),
                                  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        padding: EdgeInsets.only(left: 20, right: PS.margin),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text("流量", style: PS.normalTextStyle(),),
                                            Row(
                                              children: [
                                                Offstage(
                                                  offstage: flow == null,
                                                  child: RatingBar.builder(
                                                    initialRating: double.parse(flow?.level ?? "0"),
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: false,
                                                    itemCount: 5,
                                                    itemSize: 26,
                                                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                    itemBuilder: (context, index) => Text("${index + 1}", style: TextStyle(color: Colors.red, fontWeight: int.parse(flow?.level ?? "0") > index ? FontWeight.w700 : FontWeight.w500, fontSize: 16)),
                                                    onRatingUpdate: (rating) async {
                                                      var selectedRating = rating.toInt();
                                                      if(flow?.level == '${selectedRating}') {
                                                        //删除
                                                        await MarkAPI.instance.delete(flow!);
                                                      } else {
                                                        flow?.level = '${selectedRating}';
                                                        await MarkAPI.instance.updateMark(flow);
                                                      }
                                                      init();
                                                    },
                                                  ),
                                                ),
                                                Offstage(
                                                  offstage: flow != null,
                                                  child: RatingBar.builder(
                                                    initialRating: double.parse(flow?.level ?? "0"),
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: false,
                                                    itemCount: 5,
                                                    itemSize: 26,
                                                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                    itemBuilder: (context, index) => Text("${index + 1}", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 16)),
                                                    onRatingUpdate: (rating) async {
                                                      var selectedRating = rating.toInt();
                                                      var painMark = Mark(null, "period_flow", "${getNowDate().microsecondsSinceEpoch}", "${_selectedDay!.millisecondsSinceEpoch}",)..level='${selectedRating}';
                                                      await MarkAPI.instance.insertMark(painMark);
                                                      init();
                                                      print(rating);
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 10,)
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5,)
                              ],
                            ),
                          ),
                          //爱爱
                          Container(
                            margin: EdgeInsets.symmetric (vertical: 1),
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 50,
                                  padding: EdgeInsets.only(left: 20, right: PS.margin),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("爱爱", style: PS.normalTextStyle(),),
                                      IconButton(onPressed: () {
                                        Widget _headMenuView = Container(
                                            color: Colors.grey[50],
                                            height: 36.0,
                                            child: Row(children: [
                                              Expanded(child: Center(child: Text('时间'))),
                                              Expanded(child: Center(child: Text('措施'))),
                                              Expanded(child: Center(child: Text('时长'))),
                                            ]));

                                        final timeData = [
                                          List.generate(24, (index) => index.toString() + "时").toList(),
                                          ["无措施", "避孕套", "避孕药", "体外排精"],
                                          List.generate(99, (index) {
                                            if(index == 0) return "保密";
                                            return (index + 1).toString() + "分钟";
                                          }).toList(),
                                        ];
                                        String defaultTime = "${getNowDate().hour}时";
                                        Pickers.showMultiPicker(
                                          context,
                                          pickerStyle: PickerStyle(menu: _headMenuView, menuHeight: 36.0),
                                          data: timeData,
                                          selectData: [defaultTime, 0, 0],
                                          onConfirm: (p, position) async {
                                            print('longer >>> 返回数据下标：${position.join(',')}');
                                            print('longer >>> 返回数据类型：${p}');
                                            print('longer >>> 返回数据类型：${p.map((x) => x.runtimeType).toList()}');

                                            var loveMark = Mark(null, "love", "${getNowDate().microsecondsSinceEpoch}", "${_selectedDay!.millisecondsSinceEpoch}",)..length=p[2]..measure=p[1]..hour=p[0];
                                            await MarkAPI.instance.insertMark(loveMark);
                                            init();
                                          },
                                        );
                                      }, icon: Icon(Icons.add, color: Color(0xffA6A6A6),))
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: ListView.builder(itemBuilder: (cnx, index) {
                                    var item = loves[index];
                                    String val = "${item.hour ?? ''} | ${item.measure ?? ''} | ${item.length ?? ''}";
                                    return Container(height: 30, padding: EdgeInsets.only(left: 10), child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(val, style: PS.smallTextStyle(color: Color(0xffA6A6A6)),),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 36,
                                              child: PopupMenuButton(
                                                // icon: Icon(Icons.more_horiz,),
                                                icon: Icon(Icons.more_horiz, color: Color(0xffA6A6A6),),
                                                iconSize: 22,
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (BuildContext context){
                                                  return [
                                                      PopupMenuItem(child: Text("删除"),value: "delete",),
                                                  ];
                                                },
                                                onSelected: (Object object) async {
                                                  //删除当前爱爱记录
                                                  await MarkAPI.instance.delete(item);
                                                  init();
                                                },
                                                onCanceled: (){
                                                },
                                              ),
                                            ),
                                            // SizedBox(width: 7,)
                                          ],
                                        ),

                                      ],
                                    ));
                                  }, itemCount: loves.length, shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
                                )
                              ],
                            ),
                          ),
                          //体温
                          Container(
                            margin: EdgeInsets.symmetric (vertical: 1),
                            height: 50,
                            padding: EdgeInsets.only(left: 20, right: PS.margin),
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("体温", style: PS.normalTextStyle(),),
                                Row(
                                  children: [
                                    Offstage(offstage: temperature != null, child: IconButton(onPressed: () {
                                      var data = List.generate(101, (index) => (34.0 + index * .1).toString());
                                      if(temperature != null) {
                                        data.insert(0, '--');
                                      }
                                      _onClickItem(data, temperature?.temperature ?? "37.0", label: '℃', editItem: temperature);
                                    }
                                        , icon: Icon(Icons.add, color: Color(0xffA6A6A6),))),
                                    Offstage(offstage: temperature == null, child: Row(
                                      children: [
                                        GestureDetector(child: Text("${temperature?.temperature ?? ""} ℃", style: PS.smallTextStyle(),), onTap: () {
                                          var data = List.generate(101, (index) => (34.0 + index * .1).toString());
                                          if(temperature != null) {
                                            data.insert(0, '--');
                                          }
                                          _onClickItem(data, temperature?.temperature ?? "37.0", label: '℃', editItem: temperature);
                                        },),
                                        SizedBox(width: 17,)
                                      ],
                                    ))
                                  ],
                                )

                              ],
                            ),
                          ),
                          //体重
                          Container(
                            margin: EdgeInsets.symmetric (vertical: 1),
                            height: 50,
                            padding: EdgeInsets.only(left: 20, right: PS.margin),
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("体重", style: PS.normalTextStyle(),),
                                Row(
                                  children: [
                                    Offstage(offstage: weight != null, child: IconButton(onPressed: () async {
                                      //获取上一次默认值TODO
                                      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                      String defaultStr = sharedPreferences.getString("LASTWEIGHT") ?? "50.0";
                                      var data = List.generate(261, (index) => (20.0 + index * .5).toStringAsFixed(1));
                                      if(weight != null) {
                                        data.insert(0, '--');
                                      }
                                      _onClickItem(data, weight?.weight ?? defaultStr, label: 'KG', editItem: weight);
                                    }, icon: Icon(Icons.add, color: Color(0xffA6A6A6),))),
                                    Offstage(offstage: weight == null, child: Row(
                                      children: [
                                        GestureDetector(child: Text("${weight?.weight ?? ""} KG", style: PS.smallTextStyle(),), onTap: () async {
                                          //获取上一次默认值TODO
                                          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                          String defaultStr = sharedPreferences.getString("LASTWEIGHT") ?? "50.0";
                                          var data = List.generate(261, (index) => (20.0 + index * .5).toStringAsFixed(1));
                                          if(weight != null) {
                                            data.insert(0, '--');
                                          }
                                          _onClickItem(data, weight?.weight ?? defaultStr, label: 'KG', editItem: weight);
                                        },),
                                        SizedBox(width: 17,)
                                      ],
                                    ))
                                  ],
                                )
                              ],
                            ),
                          ),
                          //睡眠
                          Container(
                            margin: EdgeInsets.symmetric (vertical: 1),
                            height: 50,
                            padding: EdgeInsets.only(left: 20, right: PS.margin),
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("睡眠", style: PS.normalTextStyle(),),
                                Row(
                                  children: [
                                    Offstage(offstage: sleep != null, child: IconButton(onPressed: () {
                                      var data = List.generate(49, (index) => (0 + index * .5).toString());
                                      if(sleep != null) {
                                        data.insert(0, '--');
                                      }
                                      _onClickItem(data, sleep?.length ?? "8.0", label: 'H', editItem: sleep);
                                    }
                                        , icon: Icon(Icons.add, color: Color(0xffA6A6A6),))),
                                    Offstage(offstage: sleep == null, child: Row(
                                      children: [
                                        GestureDetector(child: Text("${sleep?.length ?? ""} H", style: PS.smallTextStyle(),), onTap: () {
                                          var data = List.generate(49, (index) => (0 + index * .5).toString());
                                          if(sleep != null) {
                                            data.insert(0, '--');
                                          }
                                          _onClickItem(data, sleep?.length ?? "8.0", label: "H", editItem: sleep);
                                        },),
                                        SizedBox(width: 17,)
                                      ],
                                    ))
                                  ],
                                )

                              ],
                            ),
                          ),
                          //日记
                          Container(
                            margin: EdgeInsets.symmetric (vertical: 1),
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {

                                  },
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.only(left: 20, right: PS.margin),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("日记", style: PS.normalTextStyle(),),
                                        Row(
                                          children: [
                                            Offstage(
                                              offstage: diary != null,
                                              child: IconButton(onPressed: () async {
                                                await Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                  return AddDiaryPage(_selectedDay!);
                                                }));
                                                init();

                                              }, icon: Icon(Icons.add, color: Color(0xff888888),)),
                                            ),
                                            Offstage(
                                              offstage: diary == null,
                                              child: TextButton(onPressed: () async {
                                                await Navigator.push(context, MaterialPageRoute(builder: (_) {
                                                  return AddDiaryPage(_selectedDay!, editItem: diary!,);
                                                }));
                                                init();
                                              }, child: Text("编辑", style: PS.smallTextStyle(color: Color(0xff888888)),)),
                                            )
                                          ],
                                        )

                                      ],
                                    ),
                                  ),
                                ),
                                Offstage(
                                  offstage: diary == null,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 28, right: 20, top: 0, bottom: 15),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text(diary?.diary ?? "", style: TextStyle(color: Color(0xffA6A6A6), fontSize: 15, height: 1.5), maxLines: 4, overflow: TextOverflow.ellipsis,)),
                                      ],
                                    ),

                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            ]
          ),
        ),
      ),
    );
  }

  @override
  void didPop() {
    // TODO: implement didPop
  }

  @override
  void didPopNext() {
    // TODO: implement didPopNext
  }

  @override
  void didPush() {
    // TODO: implement didPush
  }

  @override
  void didPushNext() {
    // TODO: implement didPushNext
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
