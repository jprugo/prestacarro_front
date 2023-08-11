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
    return Active(
      id: json['id'] as int,
      internalCode: json['internal_code'] as String,
      available: json['available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['internal_code'] = this.internalCode;
    data['available'] = this.available;
    return data;
  }
}
