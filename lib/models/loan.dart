import 'package:prestacarro_front/models/person.dart';

class Loan {
  int id;
  Person person;
  DateTime registrationDate;

  Loan(
      {required this.id, required this.person, required this.registrationDate});

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id_loan'] as int,
      person: Person.fromJson(json['person'] as Map<String, dynamic>),
      registrationDate:
          DateTime.parse(json['loan_registration_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_loan': id,
      'person': person.toJson(),
      'loan_registration_date': registrationDate.toIso8601String(),
    };
  }
}
