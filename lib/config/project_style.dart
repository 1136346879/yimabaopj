import 'dart:ui';

import 'package:flutter/material.dart';

class PS {
  static const double largeTextTitleSize = 36.0;  //标题文字大小
  static const double textTitleSize = 20.0;  //标题文字大小
  static const double textNormalSize = 16.0;  //普通文字大小
  static const double textSmallSize = 14.0;  //samll文字大小
  static const double textSmallerSize = 10.0;  //samller文字大小
  static const double buttonNormalHeight = 45.0;  //普通按钮大小
  static const double buttonSmallHeight = 30.0;  //普通按钮大小
  static const double margin = 8.0; //间距
  static const double smallMargin = 5.0; //间距
  static const double marginLarge = 16.0; //大间距
  static const double dividerHeight = 0.5; //分隔线高度
  //颜色
  // static const Color backgroundColor = Color.fromRGBO(1, 1, 1, 1.0);//背景色
  static const Color backgroundColor = Color(0xffFFE8E8);//背景色
  static const Color textBlackColor = Color.fromRGBO(35, 35, 35, 1.0);//文字黑色
  static const Color textBlueColor = Colors.blue;
  static const Color secondTextColor = Color.fromRGBO(255, 255, 255, 0.8);//文字黑色
  // static const Color secondColor = Color.fromRGBO(241, 64, 132, 1.0);//文字红色
  static const Color c353535 = Color(0xff333333);//#888888
  static const Color c888888 = Color(0xff888888);//#888888
  static const Color cb2b2b2 = Color(0xffb2b2b2);//#b2b2b2
  static const Color ce6e6e6 = Color(0xffe6e6e6);//#e6e6e6
  //主色调大致面三种颜色
  static const Color primaryColor = c353535;//主颜色
  static const Color secondaryColor = Color.fromRGBO(241, 64, 132, 1.0);//第二颜色 红色按钮
  static const Color tertiaryColor = Color(0xffe41818);//第三颜色 蓝色按钮
  static const Color gray = Color(0xffDDDDDD);//灰
  //TextStyle
  static TextStyle smallTextStyle({ Color color = textBlackColor, FontWeight fontWeight = FontWeight.normal}) {
    return TextStyle(fontSize: textSmallSize, color: color, fontWeight: fontWeight);
  }
  static TextStyle smallerTextStyle({ Color color = textBlackColor, FontWeight fontWeight = FontWeight.normal}) {
    return TextStyle(fontSize: textSmallerSize, color: color, fontWeight: fontWeight);
  }
  static TextStyle normalTextStyle({ Color color = textBlackColor, FontWeight fontWeight = FontWeight.normal}) {
    return TextStyle(fontSize: textNormalSize, color: color, fontWeight: fontWeight);
  }
  static TextStyle titleTextStyle({ Color color = textBlackColor, FontWeight fontWeight = FontWeight.normal}) {
    return TextStyle(fontSize: textTitleSize, color: color, fontWeight: fontWeight);
  }
  static TextStyle largeTitleTextStyle({ Color color = textBlackColor, FontWeight fontWeight = FontWeight.normal}) {
    return TextStyle(fontSize: largeTextTitleSize, color: color, fontWeight: fontWeight);
  }
  static TextStyle alertMsgTextStyle({ Color color = textBlackColor, FontWeight fontWeight = FontWeight.normal}) {
    return TextStyle(fontSize: 16, color: color, fontWeight: fontWeight);
  }
  //分割线
  static Widget defaultDivider({double horizontalPadding = margin}) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Divider(
          height: dividerHeight,
        )
    );
  }

  //小按钮

  //编码明细页列表高度进行提取
  static final codeCellHeight = 44.0;
}


