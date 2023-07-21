import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Constants/AppString.dart';

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

showToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue[400],
      textColor: Colors.white,
      fontSize: 16.0);
}




  // Function to show the AlertDialog
  void showDialogw(BuildContext context , {required VoidCallback onConfirm}) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('האם אתה בטוחח שברצונך למחוק?'),
        // content: const Text('AlertDialog description'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
         onPressed: () {
            onConfirm(); // Call the onConfirm callback passed from the SlidableAction
            Navigator.pop(context, 'OK'); // Close the dialog
          },
          child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
