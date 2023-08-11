import '../models/active.dart';
import '../models/loan.dart';
import '../models/person.dart';

class Dto {
  final String stationUrl;
  final Person person;
  final Active active;
  late String filePath = "";
  late Loan? loan;
  bool released = false;
  Dto({required this.person, required this.stationUrl, required this.active});
}