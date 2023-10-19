import 'package:flutter/material.dart';
import 'package:yimabao/config/project_style.dart';
import 'package:yimabao/pages/new_home.dart';
import 'package:yimabao/utils/dialog.dart';
import 'package:yimabao/utils/event_bus_util.dart';

import 'home_page.dart';
import 'setting_page.dart';

class MainPage extends StatefulWidget {
  final bool isShowCircleDialog;
  @override
  _MainPageState createState() => _MainPageState();
  MainPage({this.isShowCircleDialog = false});
}

class _MainPageState extends State<MainPage> {

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    if(_selectedIndex == index) return;
    if(index == 0) {
      eventBus.fire(TabChangeEvent());
    }
    setState(() {
      _selectedIndex = index;
      this._pageController.jumpToPage(this._selectedIndex);
    });
  }

  List<Widget> _bottomNavPages = []; // 底部导航栏各个可切换页面组
  late PageController _pageController = PageController(initialPage: 0);
  @override
  void initState() {
    super.initState();
    _bottomNavPages..add(NewHome())..add(SettingPage());
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      if(this.widget.isShowCircleDialog) {
        await showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
            contentPadding: EdgeInsets.all(15),
            content: CycleDialogContent(),
          );
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // Widget bottom = BottomNavigationBar(
    //   // backgroundColor: Color.fromRGBO(61, 61, 61, 1),
    //   unselectedItemColor: Color.fromRGBO(173, 173, 173, 1),
    //   selectedItemColor: Colors.white,
    //   selectedIconTheme: IconThemeData(color: Colors.white),
    //   selectedFontSize: 18,
    //   unselectedFontSize: 18,
    //   iconSize: 0,
    //   backgroundColor: Colors.black,
    //   items: <BottomNavigationBarItem>[
    //     BottomNavigationBarItem(icon: Icon(Icons.apps,), label: '记录'),
    //     BottomNavigationBarItem(icon: Icon(Icons.account_circle,), label: '我'),
    //   ],
    //   currentIndex: _selectedIndex,
    //   onTap: _onItemTapped,
    // );
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: _bottomNavPages.length == 0 ? Center(child: Text('正在加载..',),) : PageView(physics: NeverScrollableScrollPhysics(), children: _bottomNavPages, controller: _pageController,),
              ),
            ),
            // Container(height: 0.5, color: Colors.grey.shade50,)
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xffFFCCDD),
        child: Container(
          height: 40,
          child: Row(
            children: [
              Expanded(child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _onItemTapped(0);
                },
                child: Center(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text("记录", style: PS.titleTextStyle(color: _selectedIndex == 0 ? Color(0xff808080) : Color.fromRGBO(173, 173, 173, 1), fontWeight: FontWeight.normal),),
                )),
              )),
              Expanded(child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _onItemTapped(1);
                },
                child: Center(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text("我", style: PS.titleTextStyle(color: _selectedIndex == 1 ? Color(0xff808080) : Color.fromRGBO(173, 173, 173, 1), fontWeight: FontWeight.normal),),
                )),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
