class Person {
  int? id;
  final String firstName;
  String? middleName;
  final String lastName;
  String? surName;
  final String documentNumber;
  final String birthDate;
  final String sex;
  late String? fullName;

  Person(
      {this.id,
      required this.firstName,
      this.middleName,
      required this.lastName,
      this.surName,
      required this.documentNumber,
      required this.birthDate,
      required this.sex,
      this.fullName});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String,
      lastName: json['lastName'] as String,
      surName: json['surName'] as String,
      documentNumber: json['documentNumber'] as String,
      birthDate: json['birthDate'] as String,
      sex: json['sex'] as String,
      //registrationDate: DateTime.parse(json['registrationDate'] as String),
      fullName: json['fullName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['middleName'] = this.middleName;
    data['lastName'] = this.lastName;
    data['surName'] = this.surName;
    data['documentNumber'] = this.documentNumber;
    data['birthDate'] = this.birthDate;
    data['sex'] = this.sex;
    //data['registrationDate'] = this.registrationDate;
    data['fullName'] = this.fullName;
    return data;
  }
}
