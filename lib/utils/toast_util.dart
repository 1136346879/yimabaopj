import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(String msg) {
  if(Platform.isAndroid) {
    Fluttertoast.showToast(msg: msg, );
  } else {
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.CENTER);
  }

}