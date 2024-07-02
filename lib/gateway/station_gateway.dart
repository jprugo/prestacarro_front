import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/active.dart';

class StationGateway {

  Future<List> getActives(String baseUrl) async {

    var request = http.Request('POST', Uri.parse('$baseUrl/actives'));

    print("Making url to node: "+ request.url.toString());

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print('Fetched data succesfully!');
        var listOfDicts = jsonDecode(await response.stream.bytesToString());
        return listOfDicts.map((e) => Active.fromJson(e)).toList();
      } else {
        print(response.statusCode);
        throw Exception("Se recibio un codigo inesperado.");
      }
    } catch (exception) {
      print(exception);
      return List.empty();
    }
  }

  Future<Active> getActive(String baseUrl) async {

    var request = http.Request('POST', Uri.parse('$baseUrl/getRandomAvailable'));

    print("Making url to node: "+ request.url.toString());

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print('Fetched data succesfully!');
        var jsonResponse = jsonDecode(await response.stream.bytesToString());
        return Active.fromJson(jsonResponse);
        
      } else {
        print(response.statusCode);
        throw Exception("Se recibio un codigo inesperado.");
      }
    } catch (exception) {
      print(exception);
      throw Exception("No se pudo obtener un activo");
    }
  }

  Future<void> post(String stationBaseUrl, int idLoan, int idActive) async {
    print('[Station] Making release request for loan $idLoan ...');

    var body = json.encode({
      "idLoan": idLoan,
      "idActive": idActive,
    });

    var headers = {
      'Content-Type': 'application/json',
      'Content-Length': body.length.toString()
    };

    var request = http.Request('POST', Uri.parse('$stationBaseUrl/release'));
    request.headers.addAll(headers);
    request.body = body;

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('Dispatched!');
    } else {
      print(response.statusCode);
      throw Exception('Station integration failed');
    }
  }
}