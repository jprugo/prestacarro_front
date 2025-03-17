class Active {
  int id;
  String internalCode;
  bool available;

  Active({
    required this.id,
    required this.internalCode,
    required this.available,
  });

  factory Active.fromJson(Map<String, dynamic> json) {
    late String internalCode;
    if (json.containsKey("internal_code")){
      internalCode = json["internal_code"];
    }else{
      internalCode = json["internalCode"];
    }

    return Active(
      id: json['id'] as int,
      internalCode: internalCode,
      available: json['available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['internalCode'] = this.internalCode;
    data['available'] = this.available;
    return data;
  }
}
