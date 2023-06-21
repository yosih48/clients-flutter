import 'package:clientsf/screens/AppStarter.dart';
import 'package:clientsf/screens/PhoneLogin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Constants/AppString.dart';
import 'componenets/alertDialog.dart';
import 'clientdCarsd.dart';
import 'screens/actions.dart';
import 'objects/clientsCalls.dart';
import 'todoItem.dart';
import 'componenets/datePick.dart';
import 'objects/clients.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Future< void> main()
// async{
//   WidgetsFlutterBinding.ensureInitialized();
// await Firebase.initializeApp();
//   runApp(const TodoApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // runApp(const TodoApp());
  runApp(const AppStarter());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        // '/actions': (context) => actions(user: user),
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
  List<Todo> _todos = <Todo>[];

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
      // Todo client =
      //     Todo(name: name, email: mail, address: address, completed: false);

      // // _todos.add(Todo(
      // //   name: name,
      // //   completed: false,
      // //   email: mail,
      // //   address: address,
      // //   userList: [],
      // // ));

      // print(client);
      // _todos.add(client);
      // print(_todos);
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
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     _addTodoItem(_textFieldController.text,
            //         _mailFieldController.text, _addressFieldController.text);
            //     print(_todos);
            //   },
            //   child: const Text('Add'),
            // ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                addUser(_textFieldController.text, _mailFieldController.text,
                    _addressFieldController.text,_phoneFieldController.text);
                // _addTodoItem(_textFieldController.text,
                //     _mailFieldController.text, _addressFieldController.text);

                setState(() {});
              },
              child: const Text('Add user'),
            ),
          ],
        );
      },
    );
  }

  CollectionReference clients = FirebaseFirestore.instance.collection('users');
  Future<void> addUser(name, email, address, phone) {
    String clientId = generateClientId();
    // Call the user's CollectionReference to add a new user
    print(name);
    return clients
         .doc(clientId)
        .set({
            'id': clientId,
          'name': name, 
          'email': email, 
          'address': address ,
          'phone': phone ,
        })
        // .then((value) => print("User Added") )
        .then((value) {
          print("User Added");
          showToast('נשמר בהצלחה');
              _textFieldController.clear();
    _mailFieldController.clear();
    _phoneFieldController.clear();
    _addressFieldController.clear();

        })
        .catchError((error) => print("Failed to add user: $error"));
  }

  String generateClientId() {
  // Implement your logic to generate a unique client ID
  // This can be a randomly generated string, a combination of user input, or any other unique identifier generation method
  // For simplicity, we will use a timestamp-based ID in this example
  return DateTime.now().millisecondsSinceEpoch.toString();
}

  void getDataFromFirestore() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').get();
// print(snapshot);
    if (snapshot.docs.isNotEmpty) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),



// option1
      body: UserListView(),
      
// option2
      // body: ListView(
      //   padding: const EdgeInsets.symmetric(vertical: 8.0),
      //   children: _todos.map((Todo todo) {
      //     return TodoItem(
      //         todo: todo,
      //         onTodoChanged: _handleTodoChange,
      //         removeTodo: _deleteTodo);
      //   }).toList(),
      // ),

// option3
      // body: ListView.builder(
      //   itemBuilder: (context, index){
      //     return Padding(
      //       padding: const EdgeInsets.symmetric(vertical: 1.0,horizontal: 4.0),
      //       child: Card(
      //         child: ListTile(
      //           onTap: (){
      // //  updateTime(index);
      //           },
      //           title: Row(
      //             children: [
      //               Text(_todos[index].name),
      //               Text(_todos[index].address),
      //                  SizedBox(width: 8.0),
      //                  ElevatedButton(

      //                 onPressed: (){

      //                 },
      //                  child:Text('Button'))
      //             ],
      //           ),
      //                  subtitle: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Text(_todos[index].address),
      //                 Text(_todos[index].address),
      //               ],
      //             ),
      //           // leading: CircleAvatar(
      //           //   backgroundImage: AssetImage('assets/${_todos[index].flag}'),
      //           // ),
      //         ),
      //       ),
      //     );
      // },
      // itemCount:_todos.length ,
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(),
        tooltip: 'Add a Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
