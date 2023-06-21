import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController controllerMinute;

  TimeTextField({required this.controller, required this.controllerMinute});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: 'Hours'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controllerMinute,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: 'Minutes'),
          ),
        ),
        const SizedBox(width: 16),
    
      ],
    );
  }
}
