class Calls {
  Calls({
    required this.id,
    required this.call,
    required this.paid,
    required this.type,
    required this.completed,
    this.computerProduct,
    this.quantity,
    this.officeVersion,
    this.windowsLicense,
    this.officeLicense,
    // this.phone
  });
  final String id;
  String call;
  bool paid;
  String type;
  bool completed;
  // int? phone;
  String? computerProduct;
  int? quantity;
  String? officeVersion;
  bool? windowsLicense;
  bool? officeLicense;

  factory Calls.fromJson(Map<String, dynamic> json) => Calls(
        id: json["id"],
        call: json["call"],
        paid: json["paid"],
        type: json["first_name"],
        completed: json["completed"],
        computerProduct: json["computerProduct"],
        quantity: json["quantity"],
        officeVersion: json["officeVersion"],
        windowsLicense: json["windowsLicense"],
        officeLicense: json["officeLicense"],
      );
}
