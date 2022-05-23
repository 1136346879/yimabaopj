import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:yimareport/api/db_api.dart';
import 'package:yimareport/config/project_style.dart';
import 'package:yimareport/db/entities/mark.dart';
import 'package:yimareport/request/mark_api.dart';
import 'package:yimareport/request/mine_api.dart';

class WeightsPage extends StatefulWidget {
  @override
  _WeightsPageState createState() => _WeightsPageState();
}

class _WeightsPageState extends State<WeightsPage> {
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
      _list = await DBAPI.sharedInstance.markDao.findMemberMarksByOpt("weight");
    } else {
      _list = await DBAPI.sharedInstance.markDao.findLocalMarksByOpt("weight");
    }
    dataSource = _list.where((element) => element.isDeleted == 0).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("体重记录"),
          brightness: Brightness.dark,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: PS.c353535
      ),
      body: Container(
        padding: EdgeInsets.only(top: 5),
        color: Color(0xffE5E5E5),
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
                      color: Color(0xff383838),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Center(
                      child: Text("${dataSource.length - index}", style: PS.titleTextStyle(color: Colors.white),),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Row(children: [
                    Text("${DateUtil.formatDateMs(int.parse(item.dayAt), format: "yyyy年MM月dd日")}", style: PS.normalTextStyle(),),
                    SizedBox(width: 5,),
                    Text("${item.weight ?? ""} KG", style: PS.normalTextStyle(),),
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
