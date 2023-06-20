import 'clientsCalls.dart';

class Todo {
  Todo({
   required this.id,
    required this.name,
    required this.completed,
    required this.email,
    required this.address,
    required this.phone,
    this.userList
    // this.phone
  });
    final String id;
  String? name;
  String? email;
  String? address;
  String? phone;
  bool completed;
      List<Calls>?userList;
  // int? phone;



  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
      id: json["id"],
        name: json["name"],
        completed: json["completed"],
        email: json["email"],
       address: json["address"],
       phone: json["phone"],
        userList: json["data"] == null
            ? []
            : List<Calls>.from(json["data"]!.map((x) => Calls.fromJson(x))),
   
      );







}
