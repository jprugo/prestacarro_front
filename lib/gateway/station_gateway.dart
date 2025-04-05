import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/active.dart';

const STATION_TIMEOUT = 50;

class StationGateway {
  Future<List> getActives(String baseUrl) async {
    var request = http.Request('POST', Uri.parse('$baseUrl/actives'));

    print("Making url to node: " + request.url.toString());

    try {
      http.StreamedResponse response = await request.send().timeout(Duration(seconds: 50));

      if (response.statusCode == 200) {
        print('[GET] Petición de estación realizada exitosamente');
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
    var request =
        http.Request('POST', Uri.parse('$baseUrl/getRandomAvailable'));

    print("Making url to node: " + request.url.toString());

    try {
      http.StreamedResponse response = await request.send().timeout(Duration(seconds: STATION_TIMEOUT));

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

    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('${stationBaseUrl}/liberate'));

    request.body = json.encode({"id_active":idActive, "id_loan":idLoan});
    request.headers.addAll(headers);

    print("Calling service [${request.url}] ...");

     http.StreamedResponse response =
          await request.send().timeout(Duration(seconds: STATION_TIMEOUT));

    if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
  }

}
