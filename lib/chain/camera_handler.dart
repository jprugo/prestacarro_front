import 'package:prestacarro_front/gateway/camera_gateway.dart';
import 'dto.dart';
import 'handler.dart';

class CameraHandler extends Handler {

  final CameraGateway cameraGateway;  

  CameraHandler(this.cameraGateway) : super();
  
  @override
  Future<void> execute(Dto dto) async {
    print("Inicia manejo servicio camara...");
    dto.filePath = (await cameraGateway.post(dto.person.documentNumber.toString()))!;
    print("dto file path: ${dto.filePath}");
  }

}