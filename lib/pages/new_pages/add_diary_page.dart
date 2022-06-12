import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:yimareport/config/project_style.dart';
import 'package:yimareport/db/entities/mark.dart';
import 'package:yimareport/request/mark_api.dart';
import 'package:yimareport/request/mine_api.dart';
import 'package:yimareport/utils/lunar_calendar.dart';

class AddDiaryPage extends StatefulWidget {
  final DateTime selectDate;
  final Mark? editItem;
  @override
  _AddDiaryPageState createState() => _AddDiaryPageState();
  AddDiaryPage(this.selectDate, {Key? key, this.editItem}): super(key: key);
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =  TextEditingController(text: widget.editItem?.diary ?? "");

  }
  @override
  Widget build(BuildContext context) {
    // "${} ${DateUtil.getWeekday(getNowDate(), languageCode: "zh", short: true)}"
    var mdStr = "${widget.selectDate.month}月${widget.selectDate.day}日";
    var weekStr = DateUtil.getWeekday(widget.selectDate, languageCode: "zh", short: true);
    // DateUtil.formatDate(widget.selectDate.month,format: "MM月dd日");
    LunarCalendar lunarCalendar = LunarCalendar(widget.selectDate);
    String timeStr = '${lunarCalendar.getChinaMonthString()}月${LunarCalendar.getChinaDayString(lunarCalendar.day)}';
    return Scaffold(
      appBar: AppBar(title: Text("日记"),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: PS.c353535),
      body: WillPopScope(
        onWillPop: () async {
          if(_controller.text.trim() != "") {
            if(widget.editItem != null) {
              Mark copy = widget.editItem!;
              copy.diary = _controller.text;
              copy.createAt = "${widget.selectDate.millisecondsSinceEpoch}";
              await MarkAPI.instance.updateMark(copy);
            } else {
              Mark diary = Mark(null, "diary", "${DateTime.now().microsecondsSinceEpoch}", "${widget.selectDate.millisecondsSinceEpoch}", diary: _controller.text);
              await MarkAPI.instance.insertMark(diary);
            }
            //保存或者插入
            // MarkAPI.instance.insertOrUpdateMark(diary);
          } else {
            //删除
            await MarkAPI.instance.delete(widget.editItem!);
          }
          return Future.value(true);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Container(
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(mdStr, style: TextStyle(fontSize: 30, color: Color(0xffE8A7AD)),),
                    SizedBox(width: 10,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(weekStr, style: TextStyle(fontSize: 14, color: Color(0xff353535))),
                        SizedBox(height: 2,),
                        Text("农历${timeStr}", style: TextStyle(fontSize: 15, color: Color(0xffA6A6A6))),
                      ],
                    )

                  ],
                ),
              ),
              Expanded(child: Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: PS.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                child: TextFormField(
                  controller: _controller,
                  maxLines: 1000,//最多多少行
                  // minLines: 1,//最少多少行
                  style: TextStyle(color: Color(0xff353535), fontSize: 20, height: 1.5, letterSpacing: 1),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    fillColor: Colors.transparent,//背景颜⾊，必须结合filled: true,才有效
                    filled: true,//重点，必须设置为true，fillColor才有效
                    isCollapsed: true,
                    contentPadding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), //内边距设
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
