import 'dart:io';
import 'dart:math';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/api/db_api.dart';
import 'package:yimareport/config/project_config.dart';
import 'package:yimareport/config/project_style.dart';
import 'package:yimareport/db/entities/record.dart';
import 'package:yimareport/entities/version_entity.dart';
import 'package:yimareport/request/mine_api.dart';
import 'package:yimareport/utils/dialog.dart';

import 'setting_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Record? lastRecord;
  List<List<Record>> dataSource = [];
  AddRecordDateDialogController _addRecordDateDialogController = AddRecordDateDialogController();
  DateTime _now = DateTime.now();
  bool isHideOperationArea = false;
  late int doingVal = 7;
  late int cycleVal = 28;
  var lastPopTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      refreshRecord();
      getCycle();
    });
  }
  getCycle() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    doingVal = sharedPreferences.getInt(ProjectConfig.doingKey) ?? 7;
    cycleVal = sharedPreferences.getInt(ProjectConfig.cycleKey) ?? 28;
    setState(() {});
  }
  refreshRecord() async {
    lastRecord = await getLastRecord();
    dataSource = await getAllRecords();
    var _isHideOperationArea = false;
    //如果经期 > 设定值+2 自动标记经期结束, 日期为标定日期
    if(lastRecord != null) {
      //判断
      var duration = getNowDate().difference(DateUtil.getDateTime(lastRecord!.operationTime)!).inDays + 1;
      var isDoing = lastRecord!.type == 1;
      var circle = isDoing ? doingVal : cycleVal;
      if(isDoing) {
        if (duration > 14 ) {
          // 更改：经期状态持续14天，若大于14天仍未标记结束，则自动标记设定值当天结束。
          var record = Record(
              null,
              DateUtil.formatDate(DateUtil.getDateTime(lastRecord!.operationTime)!.add(Duration(days: circle - 1)) ,format: "yyyy-MM-dd"),
              DateUtil.formatDate(getNowDate(),format: "yyyy-MM-dd"),
              2
          );
          await DBAPI.sharedInstance.recordDao.insertRecord(record);
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
    var record = Record(
        null,
        DateUtil.formatDate(date,format: "yyyy-MM-dd"),
        DateUtil.formatDate(getNowDate(),format: "yyyy-MM-dd"),
        lastRecord?.type == 1 ? 2 : 1
    );
    await DBAPI.sharedInstance.recordDao.insertRecord(record);
    refreshRecord();
  }
  getLastRecord() async {
    var last = await DBAPI.sharedInstance.recordDao.findLastRecord();
    return last;
  }
  getAllRecords() async {
    List<Record>? _dataSource = await DBAPI.sharedInstance.recordDao.findAllRecords();
    List<List<Record>> result = [];
    List<Record> tempItem = [];
    _dataSource.asMap().forEach((index, element) {
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
  showAddRecordDateDialog() async {
    await MyDialog.showAddRecordDateDialog(context: context, customBody: AddRecordDateDialogContent(controller: _addRecordDateDialogController));
    setState(() {});
  }
  showAddRecordDialog() async {
    String title = "姨妈来了吗?";
    if(lastRecord != null) {
      var recordDateType = _addRecordDateDialogController.selectedRecordDate;
      var date = getNowDate();
      if(recordDateType == "昨天") {
        date = getNowDate().subtract(Duration(days: 1));
      } else if (recordDateType == "前天") {
        date = getNowDate().subtract(Duration(days: 2));
      }
      //判断
      var isDoing = lastRecord!.type == 1;
      title = isDoing ? "姨妈走了吗?" : "姨妈来了吗?";
    }

    MyDialog.showAlertDialog(context, () {
      addRecord();
    }, title: title, sureBtnTitleColor: Colors.blue, cancelBtnTitleColor: Colors.blue);
  }


  getNowDate() {
    // return _now;
    return DateTime.now();
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
    _now = date;
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
        var duration = getNowDate().difference(DateUtil.getDateTime(lastRecord!.operationTime)!).inDays + 1;
        var isDoing = lastRecord!.type == 1;
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
                              child: Text("${DateUtil.formatDateStr(lastRecord?.operationTime ?? "",format: "MM月dd日")}", style: PS.smallTextStyle(color: Colors.white),),
                            ),
                            Text("${lastRecord!.type == 1 ? "来" : "走"}", style: PS.largeTitleTextStyle(color: Colors.white),)
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
                          Text("${getNowDate().difference(DateUtil.getDateTime(lastRecord!.operationTime)!).inDays + 1}", style: TextStyle(color: Colors.white, fontSize: 120),),
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
            Offstage(
              // offstage: lastRecord?.addTime == DateUtil.formatDate(getNowDate(), format: "yyyy-MM-dd"),
              offstage: isHideOperationArea,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(onTap: showAddRecordDateDialog, child: Text("${_addRecordDateDialogController.selectedRecordDate}", style: PS.normalTextStyle(color: PS.secondTextColor),)),
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
                        child: Text("${btnTitle}", style: PS.titleTextStyle(color: Colors.white),)
                    ),
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(itemBuilder: (cxt, index) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        color: Color.fromRGBO(255, 255, 255, 0.2),
                        child: Center(
                          child: Text("${dataSource.length - index}", style: PS.titleTextStyle(color: Colors.white),),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text("姨妈期：", style: PS.normalTextStyle(color: Colors.white),),
                            SizedBox(width: 5,),
                            Text(dataSource[index].length == 2 ?  "${(DateUtil.getDateTime(dataSource[index].last.operationTime)!.difference(DateUtil.getDateTime(dataSource[index].first.operationTime)!).inDays + 1)}天" : "", style: PS.normalTextStyle(color: Colors.white),),
                          ],),
                          Row(children: [
                            Text("开始：", style: PS.normalTextStyle(color: Colors.white),),
                            SizedBox(width: 5,),
                            Text("${dataSource[index].first.operationTime}", style: PS.normalTextStyle(color: Colors.white),),
                            Text("，结束：", style: PS.normalTextStyle(color: Colors.white),),
                            Offstage(offstage: dataSource[index].length != 2, child: Text("${dataSource[index].last.operationTime}", style: PS.normalTextStyle(color: Colors.white),)),
                          ],),
                        ],
                      )
                    ],
                  ),
                );
              },
                itemCount: dataSource.length,
                shrinkWrap: false,
              ),
            )
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
                GestureDetector(onTap: showAddRecordDateDialog, child: Text("${_addRecordDateDialogController.selectedRecordDate}", style: PS.normalTextStyle(color: PS.secondTextColor),)),
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
      appBar: AppBar(
        leadingWidth: 170,
        brightness: Brightness.dark,
        elevation: 0,
        backgroundColor: PS.backgroundColor,
        leading: GestureDetector(onTap: _selectDate, child: Center(child: Text(DateUtil.formatDate(getNowDate(),format: "yyyy年MM月dd日"), style: PS.smallTextStyle(color: PS.secondTextColor)))),
        actions: [
          Center(child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return SettingPage();
                }));
                refreshRecord();
                getCycle();
              },
              child: Icon(Icons.settings, size: 32,),
          )),
          SizedBox(width: 10,)
        ],
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
}

