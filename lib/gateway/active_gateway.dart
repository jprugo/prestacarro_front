import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:prestacarro_front/models/active.dart';

class ActiveGateway {
  final String backendBaseUrl;

  ActiveGateway(this.backendBaseUrl);

  Future<Active> get() async {

    Active active;
    
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('GET', Uri.parse('$backendBaseUrl/actives/least-used'));

    print("Making url to: " + request.url.toString());

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    print(response.statusCode);
    if (response.statusCode == 200) {
      String responseStr = await response.stream.bytesToString();
      print(responseStr);
      active = Active.fromJson(jsonDecode(responseStr));
      print("Activo recuperado correctamente");
    } else {
      print('${response.reasonPhrase}');
      throw Exception("Error obteniedo activo");
    }
    return active;
  }
}
