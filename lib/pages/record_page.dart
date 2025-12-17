import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimabao/api/db_api.dart';
import 'package:yimabao/config/project_config.dart';
import 'package:yimabao/config/project_style.dart';
import 'package:yimabao/db/entities/local_record.dart';
import 'package:yimabao/db/entities/member_record.dart';
import 'package:yimabao/request/mine_api.dart';
import 'package:yimabao/utils/dialog.dart';

import 'setting_page.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with WidgetsBindingObserver {

  dynamic lastRecord;
  List<List<dynamic>> dataSource = [];
  AddRecordDateDialogController _addRecordDateDialogController = AddRecordDateDialogController();
  DateTime _now = DateTime.now();
  bool isHideOperationArea = false;
  late int doingVal = 7;
  late int cycleVal = 28;
  var lastPopTime;
  var netSubscription;
  var isFirstLoad = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await refreshRecord();
    });
  }
  refreshRecord() async {
    _now = DateTime.now(); //正式环境需要打开
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
    return result.reversed.toList();
  }


  getNowDate() {
    // String ymd = DateUtil.formatDate(_now, format: "yyyy-MM-dd");
    // String hms = DateUtil.formatDate(DateTime.now(), format: "HH:mm:ss");
    // DateTime? time = DateUtil.getDateTime("${ymd} ${hms}");
    // // DateTime.now() = date.month;
    // return time!;
    return _now;
    // return DateTime.now();
  }

  Future<void> _selectDate() async {
    return;
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _now,
      firstDate: _now,
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
        return Column(
          children: [
            Expanded(
              child: ListView.separated(itemBuilder: (cxt, index) {
                return Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                            color: Color(0xffFFCCDD),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            // border: Border.all(color: PS.cb2b2b2, width: 1)
                        ),
                        child: Center(
                          child: Text("${dataSource.length - index}", style: PS.titleTextStyle(color: Colors.white),),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(children: [
                            // Text("开始：", style: PS.normalTextStyle(color: Colors.white),),
                            // SizedBox(width: 5,),
                            Text("${DateUtil.formatDateMs(int.parse(dataSource[index].first["markAt"]), format: "yyyy年M月d日")}", style: PS.normalTextStyle(color: PS.cb2b2b2),),
                            Text(" ~ ", style: PS.normalTextStyle(color: PS.cb2b2b2),),
                            Offstage(offstage: dataSource[index].length != 2, child: Text("${DateUtil.formatDateMs(int.parse(dataSource[index].last["markAt"]), format: "yyyy年M月d日")}", style: PS.normalTextStyle(color: PS.cb2b2b2),)),
                          ],),
                          // SizedBox(width: 10,),
                          Row(children: [
                            Text(", ", style: PS.normalTextStyle(color: PS.cb2b2b2),),
                            // SizedBox(width: 5,),
                            Text(dataSource[index].length == 2 ?  "${(DateUtil.getDateTimeByMs(int.parse(dataSource[index].last["markAt"]) ).difference(DateUtil.getDateTimeByMs(int.parse(dataSource[index].first["markAt"]))).inDays + 1)}天" : "", style: PS.normalTextStyle(color: PS.cb2b2b2),),
                          ],),
                        ],
                      )
                    ],
                  ),
                );
              },
                itemCount: dataSource.length,
                shrinkWrap: false,
                separatorBuilder: (ctx, index) {
                  return Divider(height: 0.5,);
                },
              ),
            )
          ],
        );
      } else {
        return Center(
          child: Text("", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),),
        );
      }


    }
    return Scaffold(
      appBar: AppBar(
        title: Text("经期记录"),
        // brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: PS.c353535
      ),

      body: Container(
        color: PS.backgroundColor,
        padding: EdgeInsets.only(top: 5),
        child: contentView(),

      ),
    );
  }
}

