class Calls {
  Calls({
    required this.call,
    required this.paid,
    required this.type,
    // required this.address,
    // this.phone
  });
  String call;
  bool paid;
  String type;
  // bool completed;
  // int? phone;


  factory Calls.fromJson(Map<String, dynamic> json) => Calls(
        call: json["call"],
        paid: json["paid"],
        type: json["first_name"],

      );





}