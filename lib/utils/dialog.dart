import 'dart:async';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yimareport/config/project_config.dart';
import 'package:yimareport/config/project_style.dart';
import 'package:yimareport/request/mine_api.dart';
import 'package:yimareport/utils/my_router.dart';
import 'package:yimareport/view/custom_button.dart';

import 'local_noti_util.dart';

typedef DialogBtnAction = void Function();

class MyDialog {

  static showWith(BuildContext context, {required String message, bool barrierDismissible = true, required DialogBtnAction sureBtnAction , String title = "提示", String cancelBtnTitle = "取消", String sureBtnTitle = "确定", DialogBtnAction? cancelAction, bool isOnlysureBtn = false, bool onWillPopValue = true}) {
    MyDialog.showCustomDialog(context: context, msg: message, sureBtnCallback: sureBtnAction, cancelBtnTitle: cancelBtnTitle, sureBtnTitle: sureBtnTitle, title: title, barrierDismissible: barrierDismissible, cancelBtnCallback: cancelAction, isOnlySureBtn: isOnlysureBtn, onWillPopValue: onWillPopValue);
  }

  static Future<T?> showAddRecordDateDialog<T>({required BuildContext context, Widget? customBody, String title = "记录哪一天"}) {
    return showCustomDialog<T?>(context: context, isHideBottomBar: true, customBody: customBody, title: title, msg: null);
  }
  static Future<void> showAlertDialog(
      BuildContext context, VoidCallback callback,
      {String title = '提示',
        String? message,
        bool isOnlySureBtn = false,
        bool onWillPopValue = true,
        VoidCallback? cancelBtnCallback,
        bool barrierDismissible = true,
        String sureBtnTitle = "确定",
        Color sureBtnTitleColor = PS.primaryColor,
        Color cancelBtnTitleColor = PS.textBlackColor,
      }) async {
    await showCustomDialog(context: context, msg: message, cancelBtnCallback: cancelBtnCallback, sureBtnCallback: callback, title: title, isOnlySureBtn: isOnlySureBtn, onWillPopValue: onWillPopValue, barrierDismissible: barrierDismissible, sureBtnTitle: sureBtnTitle, sureBtnTitleColor: sureBtnTitleColor, cancelBtnTitleColor: cancelBtnTitleColor);
  }

  static Future<T?> showCustomDialog<T>(
      {
        required BuildContext context,
        String title = "提示",
        String? msg,
        Widget? customBody,
        String sureBtnTitle = "确定",
        Color sureBtnTitleColor = PS.primaryColor,
        VoidCallback? sureBtnCallback,
        String cancelBtnTitle = "取消",
        Color cancelBtnTitleColor = PS.textBlackColor,
        VoidCallback? cancelBtnCallback,
        bool isOnlySureBtn = false,
        bool onWillPopValue = true,
        bool barrierDismissible = true,
        bool tapSureBtnCloseDialog = true, //点确定就pop掉dialog框
        bool isHideBottomBar = false
      }) {

    return showGeneralDialog(
      context: context,
      barrierLabel: "customDialog",
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(onWillPopValue);
          },
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Material(
                  type: MaterialType.card,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              title,
                              style: PS.titleTextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            msg == null ? SizedBox(height: 0,) : Column(
                              children: <Widget>[
                                Text(
                                  msg,
                                  style: PS.alertMsgTextStyle(),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                            Offstage(
                              offstage: customBody == null,
                              child: customBody,
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: PS.ce6e6e6,
                        height: 1,
                      ),
                      Offstage(
                        offstage: isHideBottomBar,
                        child: Container(
                          child: isOnlySureBtn == true ? Row(children: <Widget>[
                            Expanded(
                              child: CustomButton(
                                child: Text(
                                  sureBtnTitle,
                                  style: PS.titleTextStyle(
                                      color: sureBtnTitleColor),
                                ),
                                height: 50,
                                color: Colors.transparent,
                                borderRadiusValue: 0,
                                onPress: () async {
                                  if(tapSureBtnCloseDialog) Navigator.of(context).removeRoute(ModalRoute.of(context) as RawDialogRoute);
                                  if (sureBtnCallback != null) {
                                    sureBtnCallback();
                                  }
                                },
                              ),
                            )
                          ],) : Row(
                            children: <Widget>[
                              Expanded(
                                child: Offstage(
                                  offstage: isOnlySureBtn == true,
                                  child: CustomButton(
                                      child: Text(
                                        cancelBtnTitle,
                                        style: PS.titleTextStyle(
                                            color: cancelBtnTitleColor),
                                      ),
                                      height: 50,
                                      color: Colors.transparent,
                                      borderRadiusValue: 0,
                                      onPress: () async {
                                        Navigator.of(context).removeRoute(ModalRoute.of(context) as RawDialogRoute);
                                        if (cancelBtnCallback != null) {
                                          cancelBtnCallback();
                                        }
                                      }
                                  ),
                                ),
                              ),
                              Offstage(
                                offstage: isOnlySureBtn == true,
                                child: Container(
                                  width: 0.5,
                                  color: PS.ce6e6e6,
                                  height: 30,
                                ),
                              ),
                              Expanded(
                                child: CustomButton(
                                  child: Text(
                                    sureBtnTitle,
                                    style: PS.titleTextStyle(
                                        color: sureBtnTitleColor),
                                  ),
                                  height: 50,
                                  color: Colors.transparent,
                                  borderRadiusValue: 0,
                                  onPress: () async {
                                    if(tapSureBtnCloseDialog) Navigator.of(context).removeRoute(ModalRoute.of(context) as RawDialogRoute);
                                    if (sureBtnCallback != null) {
                                      sureBtnCallback();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}

class AddRecordDateDialogController {
  _AddRecordDateDialogContentState? state;
  bindState(_AddRecordDateDialogContentState state) {
    this.state = state;
  }
  String get selectedRecordDate {
    return state?.result ?? "今天";
  }
}

class AddRecordDateDialogContent extends StatefulWidget {
  final AddRecordDateDialogController controller;
  AddRecordDateDialogContent({Key? key, required this.controller}): super(key: key);
  @override
  _AddRecordDateDialogContentState createState() => _AddRecordDateDialogContentState();
}

class _AddRecordDateDialogContentState extends State<AddRecordDateDialogContent> {
  // final addressController = TextEditingController();
  String result = "今天";
  final dataSource = ["前天", "昨天", "今天"];
  @override
  void initState() {
    super.initState();
    widget.controller.bindState(this);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Divider(height: 1,),
          ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (context, index){
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: (){
                      result = dataSource[index];
                      Navigator.of(context).pop(result);
                    },
                    child: Container(width: double.infinity, padding: EdgeInsets.all(12), child: Center(child: Text(dataSource[index], style: PS.normalTextStyle(color: index == 2 ? Colors.red : PS.textBlueColor),))),
                  );
              },
              separatorBuilder: (cxt, index) {
                return Divider(height: 0.5, indent: 10, endIndent: 10,);
              },
              itemCount: dataSource.length
          ),
        ],
      )
    );
  }
}

class CycleDialogContent extends StatefulWidget {
  @override
  _CycleDialogContentState createState() => _CycleDialogContentState();
}

class _CycleDialogContentState extends State<CycleDialogContent> {
  late int doingVal = 7;
  late int cycleVal = 28;
  late int doingPickerSelectedIndex;
  late int cyclePickerSelectedIndex;
  List<int> doingDataSource = List.generate(8, (index){return 3 + index;});
  List<int> cycleDataSource = List.generate(46, (index){return 15 + index;});
  @override
  void initState() {
    super.initState();
    getCycleInfo();
  }
  getCycleInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(MineAPI.instance.getAccount() != null) {
      doingVal = sharedPreferences.getInt(ProjectConfig.doingKey) ?? 7;
      cycleVal = sharedPreferences.getInt(ProjectConfig.cycleKey) ?? 28;
    } else {
      doingVal = sharedPreferences.getInt(ProjectConfig.localDoingKey) ?? 7;
      cycleVal = sharedPreferences.getInt(ProjectConfig.localCycleKey) ?? 28;
    }
    doingPickerSelectedIndex = doingDataSource.indexOf(doingVal);
    cyclePickerSelectedIndex = cycleDataSource.indexOf(cycleVal);
    setState(() {});
  }
  setCycle(int doing, int cycle) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if(MineAPI.instance.getAccount() != null) {
      sharedPreferences.setInt(ProjectConfig.doingKey, doing);
      sharedPreferences.setInt(ProjectConfig.cycleKey, cycle);
      sharedPreferences.setInt(ProjectConfig.cycleNeedSyncKey, DateTime.now().millisecondsSinceEpoch);
    } else {
      sharedPreferences.setInt(ProjectConfig.localDoingKey, doing);
      sharedPreferences.setInt(ProjectConfig.localCycleKey, cycle);
    }
    LocalNotiUtil.instance.resetNotiQueue();
    await MineAPI.instance.memberSyncCircle();

  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                GestureDetector(behavior: HitTestBehavior.opaque, onTap: (){Navigator.of(context).pop();}, child: Icon(Icons.close_outlined)),
                Text("周期设置", style: TextStyle(fontWeight: FontWeight.w600),),
                GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Icon(Icons.check),
                    onTap: () {
                      setCycle(doingVal, cycleVal);
                      Navigator.of(context).pop();
                    },
                )
            ],
          ),
          SizedBox(height: 10,),
          Divider(height: 1,),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              var selectedDoingIndex = await showDialog(context: context, builder: (BuildContext context){
                return AlertDialog(
                  contentPadding: EdgeInsets.all(15),
                  content: _CycleSubDialogContent(dataSource: doingDataSource, initIndex: doingPickerSelectedIndex, title: "修改姨妈周期",),
                );
              });
              if (selectedDoingIndex != null) {
                doingVal = doingDataSource[selectedDoingIndex];
                setState(() {});
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("姨妈期"),
                  Row(
                    children: [
                      Text("${doingVal}天"),
                      Icon(Icons.chevron_right)
                    ],
                  )
                ],
              ),
            ),
          ),
          Divider(height: 1,),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              var selectedCycleIndex = await showDialog(context: context, builder: (BuildContext context){
                return AlertDialog(
                  contentPadding: EdgeInsets.all(15),
                  content: _CycleSubDialogContent(dataSource: cycleDataSource, initIndex: cyclePickerSelectedIndex, title: "修改姨妈间隔",),
                );
              });
              if (selectedCycleIndex != null) {
                cycleVal = cycleDataSource[selectedCycleIndex];
                setState(() {});
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("间隔"),
                  Row(
                    children: [
                      Text("${cycleVal}天"),
                      Icon(Icons.chevron_right)
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleSubDialogContent extends StatefulWidget {
  final List<int> dataSource;
  final int initIndex;
  final String title;
  _CycleSubDialogContent({
    required this.dataSource,
    this.initIndex = 0,
    this.title = ""
  });
  @override
  __CycleSubDialogContentState createState() => __CycleSubDialogContentState();
}

class __CycleSubDialogContentState extends State<_CycleSubDialogContent> {
  late int _selectedIndex;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedIndex = widget.initIndex;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(behavior: HitTestBehavior.opaque, onTap: (){Navigator.of(context).pop();}, child: Icon(Icons.close_outlined)),
              Text("${widget.title}", style: TextStyle(fontWeight: FontWeight.w600),),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Icon(Icons.check),
                onTap: () {
                  //保存TODO
                  Navigator.of(context).pop(_selectedIndex);
                },
              )
            ],
          ),
          SizedBox(height: 10,),
          Container(
            height: 200,
            child: CupertinoPicker.builder(
                // diameterRatio: 2.0,
                scrollController: FixedExtentScrollController(initialItem: widget.initIndex),
                itemExtent: 45,
                childCount: widget.dataSource.length,
                onSelectedItemChanged: (index){
                  _selectedIndex = index;
                },
                itemBuilder: (BuildContext context, int index){
                  return Center(child: Text("${widget.dataSource[index]}天"));
                }
            ),
          )
        ],
      ),
    );
  }
}

class LoadingDialog{
  final Completer<BuildContext> _loadCompleter = Completer<BuildContext>();
  void showLoadingDialog(BuildContext context,String loadingText) {
    showGeneralDialog(
        context: context,
        barrierLabel: loadingText,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.2),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          if(!_loadCompleter.isCompleted)
            _loadCompleter.complete(context);
          return WillPopScope(
            child: Dialog(
                insetPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    child: Material(
                      type: MaterialType.card,
                      // color: ProjectStyle.backgroundColor,
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: 50.0,
                            height: 50.0,
                            child: SpinKitFadingCircle(
                              color: Colors.white,
                              size: 35.0,
                            ),
                          ),
                          // Container(
                          //   // child: Text(loadingText),
                          //   child: Text(""),
                          // )
                        ],
                      ),
                    ),
                  ),
                )
            ),
            onWillPop: () async {
              return false;
            },
          );
        });
  }

  Future<void> dismissLoadingDialog() async {
    BuildContext _dialogContext = await _loadCompleter.future;
    Navigator.of(_dialogContext).removeRoute(ModalRoute.of(_dialogContext) as RawDialogRoute);
  }
}
