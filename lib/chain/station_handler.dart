import '../gateway/station_gateway.dart';
import 'dto.dart';
import 'handler.dart';

class StationHandler extends Handler {

  final StationGateway stationGateway;  

  StationHandler(this.stationGateway) : super();
  
  @override
  Future<void> execute(Dto dto) async {
    print("Inicia manejo estaciones...");
    this.stationGateway.post(dto.stationUrl, dto.loan!.id, dto.active.id);
    dto.released = true;
  }

}