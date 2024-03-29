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

    request.fields.addAll({'id': id});

    final response = await request.send();

    if (response.statusCode == 201) {
      print('Picture was taken!');
      var result = json.decode(await response.stream.bytesToString());
      return result['imagePath'];
    } else {
      print(response.reasonPhrase);
      throw Exception("Camera integration exception");
    }

  }

}