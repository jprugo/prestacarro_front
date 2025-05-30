import 'package:http/http.dart' as http;
import 'dart:convert';

class CameraGateway {

  final String baseUrl;
  static const CREATE = "takepicture";

  CameraGateway(this.baseUrl);

  Future<String?> post(String id) async {
    if (baseUrl.isEmpty) return null;

    var request = http.MultipartRequest(
        'POST', Uri.parse('${baseUrl}/$CREATE'));

    print("Calling service [${request.url}] ...");
    request.fields.addAll({'id': id});

    try {
      final response = await request.send().timeout(Duration(seconds: 4));

      if (response.statusCode == 201) {
        print('[POST] Petición de cámara realizada exitosamente');
        var result = json.decode(await response.stream.bytesToString());
        print(result);
        return result['imagePath'];
      } else {
        print(response.reasonPhrase);
        throw Exception("Camera integration exception");
      }
    } catch (exception) {
      print(exception);
      return "";
    }
  }

}