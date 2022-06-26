import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:yimareport/api/db_api.dart';
import 'package:yimareport/config/project_style.dart';
import 'package:yimareport/db/entities/mark.dart';
import 'package:yimareport/request/mark_api.dart';
import 'package:yimareport/request/mine_api.dart';

class TemperaturiesPage extends StatefulWidget {
  @override
  _TemperaturiesPageState createState() => _TemperaturiesPageState();
}

class _TemperaturiesPageState extends State<TemperaturiesPage> {
  List<Mark> dataSource = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      getDataSource();
    });
  }
  getDataSource() async {
    var account = MineAPI.instance.getAccount();
    List<Mark> _list;
    if(account != null) {
      _list = await DBAPI.sharedInstance.markDao.findMemberMarksByOpt("temperature");
    } else {
      _list = await DBAPI.sharedInstance.markDao.findLocalMarksByOpt("temperature");
    }
    dataSource = _list.where((element) => element.isDeleted == 0).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("体温记录"),
          brightness: Brightness.dark,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: PS.c353535
      ),
      body: Container(
        padding: EdgeInsets.only(top: 5),
        color: PS.backgroundColor,
        child: ListView.separated(itemBuilder: (ctx, index) {
          Mark item = dataSource[index];
          return SwipeActionCell(
            key: ObjectKey(dataSource[index]),///this key is necessary
            trailingActions: <SwipeAction>[
              SwipeAction(
                  title: "删除",
                  onTap: (CompletionHandler handler) async {
                    MarkAPI.instance.delete(dataSource[index]);
                    dataSource.removeAt(index);
                    //TODO
                    setState(() {});
                  },
                  color: Colors.red),
            ],
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(color: PS.cb2b2b2, width: 1)
                    ),
                    child: Center(
                      child: Text("${dataSource.length - index}", style: PS.titleTextStyle(),),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Row(children: [
                    Text("${DateUtil.formatDateMs(int.parse(item.dayAt), format: "yyyy年MM月dd日")}   ${item.temperature ?? ""} ℃", style: PS.normalTextStyle(),),
                    // SizedBox(width: 5,),
                    // Text("${item.temperature ?? ""} ℃", style: PS.normalTextStyle(),),
                  ],)
                ],
              ),
            ),
          );
        }, itemCount: dataSource.length, separatorBuilder: (ctx, index) {
          return Divider(height: 0.5,);
        },),
      ),
    );
  }
}
