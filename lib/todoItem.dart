import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Constants/AppString.dart';
import 'objects/clients.dart';

class TodoItem extends StatelessWidget {
  TodoItem(
      {required this.todo,
      required this.onTodoChanged,
      required this.removeTodo})
      : super(key: ObjectKey(todo));

  final Todo todo;
  final void Function(Todo todo) onTodoChanged;
  final void Function(Todo todo) removeTodo;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Card(
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Client Name: ${todo.name}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Email: ${todo.email}'),
              SizedBox(height: 8),
              // Text('Phone number: ${todo.phone}'),
              // SizedBox(height: 8),
              // Text('address: ${todo.address}'),
              // SizedBox(height: 8),
              // Row(
              //   children: [
              ElevatedButton(
                onPressed: () {
        
                  Navigator.pushNamed(context, '/actions');
                },
                child: Text(AppStrings.openCall),
              ),
              //     SizedBox(width: 8),
              //     ElevatedButton(
              //       onPressed: () {
              //         removeTodo(todo);
              //       },
              //       style: ElevatedButton.styleFrom(
              //         primary: Colors.red,
              //         onPrimary: Colors.white,
              //       ),
              //       child: Icon(Icons.delete),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      );
    
  }
}