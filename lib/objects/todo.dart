class Todo {
  Todo({
    required this.name,
    required this.completed,
    required this.email,
    required this.address,
    // this.phone
  });
  String name;
  String email;
  String address;
  bool completed;
  // int? phone;

  
Map<String, dynamic> toJson(){

  return {"name": name, "email": email, "address": address};
}
}




