import 'package:dio/dio.dart';
import '../models/active.dart';

const int STATION_TIMEOUT = 60 * 1000; // en milisegundos para Dio

class StationGateway {
  final Dio _dio;

  StationGateway()
      : _dio = Dio(BaseOptions(
          connectTimeout: Duration(milliseconds: STATION_TIMEOUT),
          receiveTimeout: Duration(milliseconds: STATION_TIMEOUT),
          sendTimeout: Duration(milliseconds: STATION_TIMEOUT),
          headers: {'Content-Type': 'application/json'},
        ));

  Future<List<Active>> getActives(String baseUrl) async {
    final url = '$baseUrl/actives';
    try {
      print("Calling: $url");
      final response = await _dio.post(url);

      if (response.statusCode == 200) {
        print('[GET] Éxito en obtener activos');
        final List<dynamic> data = response.data;
        return data.map((e) => Active.fromJson(e)).toList();
      } else {
        throw Exception("Respuesta inesperada: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Error Dio: ${e.message}");
      return List.empty();
    }
  }

  Future<Active> getActive(String baseUrl) async {
    final url = '$baseUrl/getRandomAvailable';
    try {
      print("Calling: $url");
      final response = await _dio.post(url);

      if (response.statusCode == 200) {
        print('Activo obtenido correctamente');
        return Active.fromJson(response.data);
      } else {
        throw Exception("Respuesta inesperada: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Error Dio: ${e.message}");
      throw Exception("No se pudo obtener un activo");
    }
  }

  Future<void> post(String stationBaseUrl, int idLoan, int idActive) async {
    final url = '$stationBaseUrl/liberate';
    final payload = {
      "id_active": idActive,
      "id_loan": idLoan,
    };

    try {
      print("Liberando activo...");
      final response = await _dio.post(url, data: payload);

      if (response.statusCode == 200) {
        print("Liberación exitosa: ${response.data}");
      } else {
        print("Error en la liberación: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Error en POST liberate: ${e.message}");
    }
  }
}
