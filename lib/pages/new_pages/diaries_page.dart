import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:yimabao/api/db_api.dart';
import 'package:yimabao/config/project_style.dart';
import 'package:yimabao/db/entities/mark.dart';
import 'package:yimabao/request/mark_api.dart';
import 'package:yimabao/request/mine_api.dart';

import 'add_diary_page.dart';

class DiariesPage extends StatefulWidget {
  @override
  _DiariesPageState createState() => _DiariesPageState();
}

class _DiariesPageState extends State<DiariesPage> {
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
      _list = await DBAPI.sharedInstance.markDao.findMemberMarksByOpt("diary");
    } else {
      _list = await DBAPI.sharedInstance.markDao.findLocalMarksByOpt("diary");
    }
    dataSource = _list.where((element) => element.isDeleted == 0).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("所有日记"),
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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return AddDiaryPage(DateUtil.getDateTimeByMs(int.parse(item.dayAt),), editItem: item,);
                }));
                getDataSource();
              },
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                child: Column(
                  children: [
                    Row(
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
                          Text("${DateUtil.formatDateMs(int.parse(item.dayAt), format: "yyyy年MM月dd日")}", style: PS.normalTextStyle(),),
                        ],),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: Text(item?.diary ?? "", style: TextStyle(color: Color(0xffA6A6A6), fontSize: 15, height: 1.5), maxLines: 4, overflow: TextOverflow.ellipsis,)),
                      ],
                    )
                  ],
                ),
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
