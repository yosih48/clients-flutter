class Calls {
  Calls({
    required this.id,
    required this.call,
    required this.paid,
    required this.type,
    required this.completed,
    // this.phone
  });
  final String id;
  String call;
  bool paid;
  String type;
  bool completed;
  // int? phone;

  factory Calls.fromJson(Map<String, dynamic> json) => Calls(
        id: json["id"],
        call: json["call"],
        paid: json["paid"],
        type: json["first_name"],
        completed: json["completed"],
      );
}
