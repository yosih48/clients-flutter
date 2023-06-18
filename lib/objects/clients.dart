import 'clientsCalls.dart';

class Todo {
  Todo({
   required this.id,
    required this.name,
    required this.completed,
    required this.email,
    required this.address,
    this.userList
    // this.phone
  });
    final String id;
  String? name;
  String? email;
  String? address;
  bool completed;
      List<Calls>?userList;
  // int? phone;



  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
      id: json["id"],
        name: json["name"],
        completed: json["completed"],
        email: json["email"],
       address: json["address"],
        userList: json["data"] == null
            ? []
            : List<Calls>.from(json["data"]!.map((x) => Calls.fromJson(x))),
   
      );







}
