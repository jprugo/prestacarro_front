import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:prestacarro_front/models/person.dart';

class PersonGateway {
  final String backendBaseUrl;

  PersonGateway(this.backendBaseUrl);

  Future<Person> post(Person person) async {
    
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('POST', Uri.parse('$backendBaseUrl/persons'));

    print("Making url to: " + request.url.toString());

    request.headers.addAll(headers);

    request.body = jsonEncode(person.toJson());

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201 || response.statusCode == 208) {
      String responseStr = await response.stream.bytesToString();
      person = Person.fromJson(jsonDecode(responseStr));
      print("Person created succesfully!");
    } else {
      print('${response.reasonPhrase}');
      throw Exception("Error creando persona");
    }
    return person;
  }
}
