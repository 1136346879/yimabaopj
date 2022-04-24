import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class NewHome extends StatefulWidget {
  @override
  _NewHomeState createState() => _NewHomeState();
}

class _NewHomeState extends State<NewHome> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("新的首页"),),
      body: Container(
        child: TableCalendar(
          firstDay: DateTime.utc(2021, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          // headerVisible: false,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'zh_CN',
          calendarFormat: _calendarFormat,
          headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false
          ),
          calendarStyle: CalendarStyle(
            cellMargin: EdgeInsets.fromLTRB(1,3,1,1),
            // isTodayHighlighted: false,
            // todayDecoration: BoxDecoration(shape: BoxShape.rectangle),
            // holidayDecoration: BoxDecoration(shape: BoxShape.rectangle,),
            // selectedDecoration: BoxDecoration(border: Border.all(color: Colors.redAccent, width: 1), borderRadius: BorderRadius.all(Radius.circular(8)), shape: BoxShape.rectangle,),
            selectedTextStyle: TextStyle(color: Colors.black),
            defaultDecoration: BoxDecoration(),
            weekendDecoration: BoxDecoration(),
          ),
          calendarBuilders: CalendarBuilders(
            outsideBuilder: (context, day, focusedDay) {
                return SizedBox();
            },
            defaultBuilder: (context, day, focusedDay) {
                var text = DateFormat.d().format(day);
                return Container(
                  // child: Center(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.redAccent, width: 1)), child: Text(text))),
                  child: Center(child: Text(text)),
                );
            },
            todayBuilder: (context, day, focusedDay) {
              var text = DateFormat.d().format(day);
              return Container(
                margin: EdgeInsets.all(2),
                child: Center(child: Container(padding: EdgeInsets.all(1), decoration: BoxDecoration(border: Border.all(color: Color(0xFF383838), width: 1), borderRadius: BorderRadius.all(Radius.circular(8))), child: Text(text))),
              );
            },
            // markerBuilder: (context,  day, events) {
            //   return Container(
            //     margin: EdgeInsets.all(2),
            //     color: Colors.black12,
            //     child: Center(child: Text("456")),
            //   );
            // },
            selectedBuilder: (context, day, focusedDay) {
              var text = DateFormat.d().format(day);
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(6))
                ),
                child: Center(child: Text(text),),
              );
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
    );
  }
}
