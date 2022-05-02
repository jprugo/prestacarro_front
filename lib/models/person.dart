class Person {
  int? id;
  String? firstName;
  String? middleName;
  String? lastName;
  String? surName;
  String? documentNumber;
  String? birthDate;
  String? sex;
  //String? registrationDate;
  String? fullName;

  Person(
      {this.id,
      this.firstName,
      this.middleName,
      this.lastName,
      this.surName,
      this.documentNumber,
      this.birthDate,
      this.sex,
      this.fullName});

  Person.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    middleName = json['middleName'];
    lastName = json['lastName'];
    surName = json['surName'];
    documentNumber = json['documentNumber'];
    birthDate = json['birthDate'];
    sex = json['sex'];
    //registrationDate = json['registrationDate'];
    fullName = json['fullName'];
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
