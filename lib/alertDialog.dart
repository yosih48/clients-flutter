import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Constants/AppString.dart';


void showAlertDialog(BuildContext context, String title, {String? subtitle}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: subtitle != null ? Text(subtitle) : null,
        actions: [
          TextButton(
            child: const Text(AppStrings.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

showToast(String text){
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}