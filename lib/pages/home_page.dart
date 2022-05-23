import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/api/db_api.dart';
import 'package:yimareport/config/project_config.dart';
import 'package:yimareport/config/project_style.dart';
import 'package:yimareport/db/entities/local_record.dart';
import 'package:yimareport/db/entities/member_record.dart';
import 'package:yimareport/request/mine_api.dart';
import 'package:yimareport/utils/dialog.dart';
import 'package:yimareport/utils/event_bus_util.dart';

import '../main.dart';
import 'record_page.dart';
import 'setting_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin implements RouteAware {

  dynamic lastRecord;
  Map<String, dynamic> dataSource = {"index": 0};
  AddRecordDateDialogController _addRecordDateDialogController = AddRecordDateDialogController();
  DateTime _now = DateTime.now();
  bool isHideOperationArea = false;
  late int doingVal = 7;
  late int cycleVal = 28;
  var lastPopTime;
  var netSubscription;
  var isFirstLoad = true;
  StreamSubscription? _tabChangeSubscription;
  @override
  void initState() {
    super.initState();
    _tabChangeSubscription = eventBus.on<TabChangeEvent>().listen((event) {
      getCycle();
      refreshRecord();
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      refreshRecord();
      await MineAPI.instance.memberSyncData();
      await getCycle();
      await refreshRecord();
    });
    WidgetsBinding.instance?.addObserver(this);
    netSubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      if(result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        if(isFirstLoad) {
          isFirstLoad = false;
          return;
        }
        //监听网络变化
        await MineAPI.instance.memberSyncData();
        await MineAPI.instance.memberSyncCircle();
        await refreshRecord();
        await getCycle();
      }
    });
  }
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
    if(state == AppLifecycleState.paused) {
      print('APP进入后台');
    } else  if (state == AppLifecycleState.resumed) {
      print('APP进入前台');
      await MineAPI.instance.memberSyncData();
      await MineAPI.instance.memberSyncCircle();
      await refreshRecord();
      await getCycle();
    } else  if (state == AppLifecycleState.inactive) {
      print('APP进入xx');
    }
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }


  ///移除监听器
  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    netSubscription.cancel();
    routeObserver.unsubscribe(this);
    _tabChangeSubscription?.cancel();
    super.dispose();
  }
  getCycle() async {
    await MineAPI.instance.memberSyncCircle();
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
  refreshRecord() async {
    // _now = DateTime.now(); //正式环境需要打开
    dataSource = await getAllRecords();
    lastRecord = await getLastRecord();
    var _isHideOperationArea = false;
    //如果经期 > 设定值+2 自动标记经期结束, 日期为标定日期
    if(lastRecord != null) {
      //判断
      var duration = getNowDate().difference(DateUtil.getDateTimeByMs(int.parse(lastRecord["markAt"]))).inDays + 1;
      var isDoing = lastRecord["type"] == 1;
      var circle = isDoing ? doingVal : cycleVal;
      if(isDoing) {
        if (duration > 14 ) {
          // 更改：经期状态持续14天，若大于14天仍未标记结束，则自动标记设定值当天结束。
          // var record = Record(
          //     null,
          //     DateUtil.formatDate(DateUtil.getDateTime(lastRecord!.operationTime)!.add(Duration(days: circle - 1)) ,format: "yyyy-MM-dd"),
          //     DateUtil.formatDate(getNowDate(),format: "yyyy-MM-dd"),
          //     2
          // );
          // await DBAPI.sharedInstance.recordDao.insertRecord(record);
          // var record = LocalRecord()..markAt = DateUtil.getDateTimeByMs(lastRecord!.markAt!).add(Duration(days: circle - 1)).millisecondsSinceEpoch..createAt = getNowDate().millisecondsSinceEpoch..type = 2;
          var record = LocalRecord(
              null,
              "${DateUtil.getDateTimeByMs(int.parse(lastRecord["markAt"])).add(Duration(days: circle - 1)).millisecondsSinceEpoch}",
              "${getNowDate().millisecondsSinceEpoch}",
              2
          );
          // await DBAPI.sharedInstance.localRecordDao.insertRecord(record);
          await MineAPI.instance.insertRecord(record, buildContext: context);
          refreshRecord();
        }
        else if (duration < 3) {
          _isHideOperationArea = true;
        }
      } else {
        if(duration < 15) {
          _isHideOperationArea = true;
        }
      }
    }
    isHideOperationArea = _isHideOperationArea;
    setState(() {});
  }
  addRecord() async {
    var recordDateType = _addRecordDateDialogController.selectedRecordDate;
    var date = getNowDate();
    if(recordDateType == "昨天") {
      date = getNowDate().subtract(Duration(days: 1));
    } else if (recordDateType == "前天") {
      date = getNowDate().subtract(Duration(days: 2));
    }
    // var record = Record(
    //     null,
    //     DateUtil.formatDate(date,format: "yyyy-MM-dd"),
    //     DateUtil.formatDate(getNowDate(),format: "yyyy-MM-dd"),
    //     lastRecord?.type == 1 ? 2 : 1
    // );
    // await DBAPI.sharedInstance.recordDao.insertRecord(record);
    // var record = LocalRecord()..markAt = date.millisecondsSinceEpoch..createAt = getNowDate().millisecondsSinceEpoch..type = lastRecord?.type == 1 ? 2 : 1;
    var account = MineAPI.instance.getAccount();
    if(account != null) {
      var record = MemberRecord(
          null,
          "${date.millisecondsSinceEpoch}",
          "${getNowDate().millisecondsSinceEpoch}",
          lastRecord == null ? 1 : lastRecord["type"] == 1 ? 2 : 1,
          account.user_id!
      );
      await MineAPI.instance.insertRecord(record);
    } else {
      var record = LocalRecord(
          null,
          "${date.millisecondsSinceEpoch}",
          "${getNowDate().millisecondsSinceEpoch}",
          lastRecord == null ? 1 : lastRecord["type"] == 1 ? 2 : 1
      );
      await MineAPI.instance.insertRecord(record);
    }
    // await DBAPI.sharedInstance.localRecordDao.insertRecord(record);

    refreshRecord();
  }
  getLastRecord() async {
    // var last = await DBAPI.sharedInstance.localRecordDao.findLastRecord();
    // return last;
    var last = await MineAPI.instance.getLastRecord();
    return last;
  }
  getAllRecords() async {
    // List<LocalRecord>? _dataSource = await DBAPI.sharedInstance.localRecordDao.findAllRecords();
    List<dynamic>? _dataSource = await MineAPI.instance.getAllRecord();
    print("展示数据长度${_dataSource?.length}");
    List<List<dynamic>> result = [];
    List<dynamic> tempItem = [];
    _dataSource?.asMap().forEach((index, element) {
      tempItem.add(element);
      if(tempItem.length == 2) {
        result.add(tempItem);
        tempItem = [];
      }
    });
    if(tempItem.length > 0) {
      result.add(tempItem);
    }
    // return result.reversed.toList();
    var reverList = result.reversed.toList();
    if(reverList.length > 0) {
      return {'index': reverList.length, "data": reverList.first};
    }
  }
  showAddRecordDateDialog() async {
    var r = await MyDialog.showAddRecordDateDialog(context: context, customBody: AddRecordDateDialogContent(controller: _addRecordDateDialogController));
    setState(() {});
    return r;
  }
  showAddRecordDialog() async {
    var hasCheck = await showAddRecordDateDialog();
    if(hasCheck == null) return;
    String title = "姨妈来了吗?";
    String title2 = "";
    var recordDateType;
    recordDateType = _addRecordDateDialogController.selectedRecordDate;
    var date = getNowDate();
    if(recordDateType == "昨天") {
      date = getNowDate().subtract(Duration(days: 1));
    } else if (recordDateType == "前天") {
      date = getNowDate().subtract(Duration(days: 2));
    }
    title2 = "${DateUtil.formatDate(date, format: 'MM月dd日')}，${recordDateType}";
    if(lastRecord != null) {
      //判断
      var isDoing = lastRecord["type"] == 1;
      title = isDoing ? "姨妈走了吗?" : "姨妈来了吗?";
    }

    MyDialog.showAlertDialog(context, () {
      addRecord();
    }, title: title, message: title2, sureBtnTitleColor: Colors.blue, cancelBtnTitleColor: Colors.blue);
  }


  getNowDate() {
    String ymd = DateUtil.formatDate(_now, format: "yyyy-MM-dd");
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
    refreshRecord();
  }

  @override
  Widget build(BuildContext context) {
    Widget contentView() {
      if(lastRecord != null) {
        //判断
        var duration = getNowDate().difference(DateUtil.getDateTimeByMs(int.parse(lastRecord["markAt"]))).inDays + 1;
        var isDoing = lastRecord["type"] == 1;
        var circle = isDoing ? doingVal : cycleVal;
        var tip = "";
        if(isDoing) {
          // if(duration < circle && circle - duration == 1) {
          //   tip = "明天结束";
          // } else
            if(duration < circle) {
            //
            tip = "${circle - duration}天后结束";
          } else if (duration == circle) {
            tip = "今天结束";
          }
          else if (duration > circle) {
            tip = "多了${duration - circle}天";
          }
        } else {
          // if(duration < circle && circle - duration == 1) {
          //   tip = "预计明天来";
          // } else
            if(duration < circle) {
            //
            tip = "${circle - duration}天后来";
          }
            else if (duration == circle) {
            // tip = "预计今天来";
            tip = "今天来";
          }
          else if (duration > circle && duration <= circle * 2) {
            // tip = "姨妈迷路了";
            tip = "晚了${duration - circle}天";
          }
          else if (duration > circle * 2) {
            tip = "建议就医";
          }
        }
        String btnTitle = isDoing ? "姨妈走了" : "姨妈来了";
        Widget RecordContainer = Container();
        if(dataSource["index"] != 0) {
          RecordContainer = Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  color: Color.fromRGBO(255, 255, 255, 0.2),
                  child: Center(
                    child: Text("${dataSource["index"]}", style: PS.titleTextStyle(color: Colors.white),),
                  ),
                ),
                SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row(children: [
                    //   Text("姨妈期：", style: PS.normalTextStyle(color: Colors.white),),
                    //   SizedBox(width: 5,),
                    //   Text("", style: PS.normalTextStyle(color: Colors.white),),
                    // ],),
                    // Row(children: [
                    //   // Text("开始：", style: PS.normalTextStyle(color: Colors.white),),
                    //   // SizedBox(width: 5,),
                    //   Text("${DateUtil.formatDateMs(int.parse(dataSource?["data"]?["markAt"]), format: "yyyy.M.d")}", style: PS.normalTextStyle(color: Colors.white),),
                    //   Text(" - ", style: PS.normalTextStyle(color: Colors.white),),
                    //   // Offstage(offstage: dataSource["data"].length != 2, child: Text("${DateUtil.formatDateMs(int.parse(dataSource["data"].last["markAt"]), format: "yyyy.M.d")}", style: PS.normalTextStyle(color: Colors.white),)),
                    // ],),
                    Row(children: [
                      Text("姨妈期：", style: PS.normalTextStyle(color: Colors.white),),
                      SizedBox(width: 5,),
                      Text(dataSource["data"].length == 2 ?  "${(DateUtil.getDateTimeByMs(int.parse(dataSource["data"].last["markAt"]) ).difference(DateUtil.getDateTimeByMs(int.parse(dataSource["data"].first["markAt"]))).inDays + 1)}天" : "", style: PS.normalTextStyle(color: Colors.white),),
                    ],),
                    Row(children: [
                      // Text("开始：", style: PS.normalTextStyle(color: Colors.white),),
                      // SizedBox(width: 5,),
                      Text("${DateUtil.formatDateMs(int.parse(dataSource["data"].first["markAt"]), format: "yyyy.M.d")}", style: PS.normalTextStyle(color: Colors.white),),
                      Text(" - ", style: PS.normalTextStyle(color: Colors.white),),
                      Offstage(offstage: dataSource["data"].length != 2, child: Text("${DateUtil.formatDateMs(int.parse(dataSource["data"].last["markAt"]), format: "yyyy.M.d")}", style: PS.normalTextStyle(color: Colors.white),)),
                    ],),
                  ],
                )
              ],
            ),
          );
        }
        return Column(
          children: [
            Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              height: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.4) ,
              decoration: new BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                //设置四周边框
                border: new Border.all(width: 1, color: Colors.grey.shade800),
                boxShadow: [BoxShadow(color: Colors.grey.shade800, blurRadius: 9.0)],
              ),
              child: Stack(

                children: [
                  Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text("${DateUtil.formatDateMs(int.parse(lastRecord['markAt']),format: "MM月dd日")}", style: PS.smallTextStyle(color: Colors.white),),
                            ),
                            Text("${lastRecord["type"] == 1 ? "来" : "走"}", style: PS.largeTitleTextStyle(color: Colors.white),)
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text("${tip}", style: PS.smallTextStyle(color: Colors.white),),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30.0, right: 5),
                            child: Text("第", style: PS.titleTextStyle(color: Colors.white),),
                          ),
                          Text("${getNowDate().difference(DateUtil.getDateTimeByMs(int.parse(lastRecord["markAt"]))).inDays + 1}", style: TextStyle(color: Colors.white, fontSize: 120),),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30.0, left: 5),
                            child: Text("天", style: PS.titleTextStyle(color: Colors.white),),
                          )
                        ],
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            // Offstage(
            //   offstage: dataSource["index"] == 0,
            //   child: Container(
            //     padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
            //     child: Row(
            //       children: [
            //         Container(
            //           width: 45,
            //           height: 45,
            //           color: Color.fromRGBO(255, 255, 255, 0.2),
            //           child: Center(
            //             child: Text("${dataSource["index"]}", style: PS.titleTextStyle(color: Colors.white),),
            //           ),
            //         ),
            //         SizedBox(width: 10,),
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Row(children: [
            //               Text("姨妈期：", style: PS.normalTextStyle(color: Colors.white),),
            //               SizedBox(width: 5,),
            //               Text("", style: PS.normalTextStyle(color: Colors.white),),
            //             ],),
            //             Row(children: [
            //               // Text("开始：", style: PS.normalTextStyle(color: Colors.white),),
            //               // SizedBox(width: 5,),
            //               Text("${DateUtil.formatDateMs(int.parse(dataSource?["data"]?["markAt"]), format: "yyyy.M.d")}", style: PS.normalTextStyle(color: Colors.white),),
            //               Text(" - ", style: PS.normalTextStyle(color: Colors.white),),
            //               // Offstage(offstage: dataSource["data"].length != 2, child: Text("${DateUtil.formatDateMs(int.parse(dataSource["data"].last["markAt"]), format: "yyyy.M.d")}", style: PS.normalTextStyle(color: Colors.white),)),
            //             ],),
            //           ],
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            GestureDetector(
                behavior: HitTestBehavior.opaque,
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return RecordPage();
                }));
                refreshRecord();
                getCycle();
              },
                child: Column(
                  children: [
                    Container(
                      decoration: new BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 0.2),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
                        // borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        //设置四周边框
                        // border: new Border.all(width: 1, color: Colors.grey.shade800),
                        // boxShadow: [BoxShadow(color: Colors.grey.shade800, blurRadius: 9.0)],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: double.infinity,
                      height: 40,
                      child: Center(
                        child: Text("历史记录", style: PS.normalTextStyle(color: Colors.white70),),
                      ),
                    ),
                    RecordContainer,
                  ],
                )
            ),
            Offstage(
              // offstage: lastRecord?.addTime == DateUtil.formatDate(getNowDate(), format: "yyyy-MM-dd"),
              offstage: isHideOperationArea,
              child: Column(
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     GestureDetector(onTap: showAddRecordDateDialog, child: Text("${_addRecordDateDialogController.selectedRecordDate}", style: PS.normalTextStyle(color: PS.secondTextColor),)),
                  //   ],
                  // ),
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
                    width: double.infinity,
                    height: 85,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color.fromRGBO(255, 255, 255, 0.1)),
                          elevation: MaterialStateProperty.all(0),
                          shape: MaterialStateProperty.all(
                              StadiumBorder(
                                  side: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Colors.transparent,
                                  )
                              )
                          ),//圆角弧度
                        ),
                        onPressed: showAddRecordDialog,
                        child: Text("${btnTitle}", style: PS.titleTextStyle(color: Colors.white),)
                    ),
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),

            // Expanded(
            //   child: ListView.builder(itemBuilder: (cxt, index) {
            //     return Container(
            //       padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
            //       child: Row(
            //         children: [
            //           Container(
            //             width: 45,
            //             height: 45,
            //             color: Color.fromRGBO(255, 255, 255, 0.2),
            //             child: Center(
            //               child: Text("${dataSource.length - index}", style: PS.titleTextStyle(color: Colors.white),),
            //             ),
            //           ),
            //           SizedBox(width: 10,),
            //           Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Row(children: [
            //                 Text("姨妈期：", style: PS.normalTextStyle(color: Colors.white),),
            //                 SizedBox(width: 5,),
            //                 Text(dataSource[index].length == 2 ?  "${(DateUtil.getDateTimeByMs(int.parse(dataSource[index].last["markAt"]) ).difference(DateUtil.getDateTimeByMs(int.parse(dataSource[index].first["markAt"]))).inDays + 1)}天" : "", style: PS.normalTextStyle(color: Colors.white),),
            //               ],),
            //               Row(children: [
            //                 // Text("开始：", style: PS.normalTextStyle(color: Colors.white),),
            //                 // SizedBox(width: 5,),
            //                 Text("${DateUtil.formatDateMs(int.parse(dataSource[index].first["markAt"]), format: "yyyy.M.d")}", style: PS.normalTextStyle(color: Colors.white),),
            //                 Text(" - ", style: PS.normalTextStyle(color: Colors.white),),
            //                 Offstage(offstage: dataSource[index].length != 2, child: Text("${DateUtil.formatDateMs(int.parse(dataSource[index].last["markAt"]), format: "yyyy.M.d")}", style: PS.normalTextStyle(color: Colors.white),)),
            //               ],),
            //             ],
            //           )
            //         ],
            //       ),
            //     );
            //   },
            //     itemCount: dataSource.length,
            //     shrinkWrap: false,
            //   ),
            // )
          ],
        );
      } else {
        return Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 100),
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 1.5,
                child: Center(
                  child: Text(DateUtil.formatDate(getNowDate(),format: "yyyy年MM月dd日"), style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // GestureDetector(onTap: showAddRecordDateDialog, child: Text("${_addRecordDateDialogController.selectedRecordDate}", style: PS.normalTextStyle(color: PS.secondTextColor),)),
              ],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
              width: double.infinity,
              height: 85,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color.fromRGBO(255, 255, 255, 0.1)),
                    elevation: MaterialStateProperty.all(0),
                    shape: MaterialStateProperty.all(
                        StadiumBorder(
                            side: BorderSide(
                              style: BorderStyle.solid,
                              color: Colors.transparent,
                            )
                        )
                    ),//圆角弧度
                  ),
                  onPressed: showAddRecordDialog,
                  child: Text("姨妈来了", style: PS.titleTextStyle(color: Colors.white),)
              ),
            )
          ],
        );
      }


    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          leadingWidth: 170,
          brightness: Brightness.light,
          elevation: 0,
          backgroundColor: PS.backgroundColor,
          leading: GestureDetector(onTap: _selectDate, child: Center(child: Row(
            children: [
              SizedBox(width: 10,),
              Text("${DateUtil.formatDate(getNowDate(),format: "MM.dd")} ${DateUtil.getWeekday(getNowDate(), languageCode: "zh", short: true)}", style: PS.smallTextStyle(color: PS.secondTextColor)),
            ],
          ))),
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
          child: contentView(),

        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void didPop() {
    // TODO: implement didPop
    print("didPop");
  }

  @override
  void didPopNext() {
    // TODO: implement didPopNext
    print("didPopNext");

  }

  @override
  void didPush() {
    // TODO: implement didPush
    print("didPush");
  }

  @override
  void didPushNext() {
    print("didPushNext");
    // TODO: implement didPushNext
  }
}

