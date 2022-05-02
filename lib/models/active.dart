class idActive {
  int? id;
  String? internalCode;
  bool? available;

  idActive({
    this.id,
    this.internalCode,
    this.available,
  });

  idActive.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    internalCode = json['internal_code'];
    available = json['available'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['internal_code'] = this.internalCode;
    data['available'] = this.available;
    return data;
  }
}
