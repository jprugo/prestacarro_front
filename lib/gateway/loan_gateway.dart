import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:prestacarro_front/models/loan.dart';

class LoanGateway {

  final String backendBaseUrl;
  static const CREATE = "loans";

  LoanGateway(this.backendBaseUrl);

  Future<Loan> post(int idPerson, int idActive) async {
    // logic
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('POST', Uri.parse('$backendBaseUrl/$CREATE'));

    request.body = json.encode({
      "idPerson": idPerson,
      "idActive": idActive,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      print("Respuesta correcta!");
      return Loan.fromJson(jsonDecode(await response.stream.bytesToString()));

    }else{
      throw Exception("Backend integration exception");
    }
  }
}