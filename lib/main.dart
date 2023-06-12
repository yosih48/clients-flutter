import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Constants/AppString.dart';
import 'actions.dart';
import 'todoItem.dart';
import 'datePick.dart';
import 'objects/todo.dart';

// Future< void> main()
// async{
//   WidgetsFlutterBinding.ensureInitialized();
// await Firebase.initializeApp();
//   runApp(const TodoApp());
// }

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/actions': (context) => MyWidget(),
        '/date': (context) => HomePage()
      },
      title: 'Todo Manage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Clients'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _TodoListState();
}

class _TodoListState extends State<MyHomePage> {
  final List<Todo> _todos = <Todo>[];
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _mailFieldController = TextEditingController();
  final TextEditingController _phoneFieldController = TextEditingController();
  final TextEditingController _addressFieldController = TextEditingController();
//  final IntTextEditingController _phoneFieldController =
//       IntTextEditingController();

  void _addTodoItem(String name, String mail, String address
      // , int phone
      ) {
    setState(() {
      _todos.add(Todo(
        name: name, completed: false, email: mail, address: address,
        // , phone: phone
      ));
      print(_todos.length);
      print(_todos);
    });
    _textFieldController.clear();
    _mailFieldController.clear();
    _phoneFieldController.clear();
    _addressFieldController.clear();
  }

  void _handleTodoChange(Todo todo) {
    setState(() {
      todo.completed = !todo.completed;
    });
  }

  void _deleteTodo(Todo todo) {
    setState(() {
      _todos.removeWhere((element) => element.name == todo.name);
    });
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      // T: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a todo'),
          // content: TextField(
          //   controller: _textFieldController,
          //   decoration: const InputDecoration(hintText: 'Type your todo'),
          //   autofocus: true,
          // ),
          content: Column(
            children: [
              TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(hintText: 'Type your name'),
                autofocus: true,
              ),
              TextField(
                controller: _mailFieldController,
                decoration: const InputDecoration(hintText: 'Type your email'),
                autofocus: true,
              ),
              TextField(
                controller: _phoneFieldController,
                decoration:
                    const InputDecoration(hintText: 'Type your phone number'),
                autofocus: true,
              ),
              TextField(
                controller: _addressFieldController,
                decoration:
                    const InputDecoration(hintText: 'Type your phone address'),
                autofocus: true,
              ),
            ],
          ),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _addTodoItem(_textFieldController.text,
                    _mailFieldController.text, _addressFieldController.text);
                print(_todos);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _todos.map((Todo todo) {
          return TodoItem(
              todo: todo,
              onTodoChanged: _handleTodoChange,
              removeTodo: _deleteTodo);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(),
        tooltip: 'Add a Todo',
        child: const Icon(Icons.add),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
