import 'package:prestacarro_front/gateway/loan_gateway.dart';
import 'dto.dart';
import 'handler.dart';

class BackendHandler extends Handler {

  final LoanGateway loanGateway;  

  BackendHandler(this.loanGateway) : super();
  
  @override
  Future<void> execute(Dto dto) async {
    print("Inicia manejo de prestamos...");
    dto.loan = await loanGateway.post(dto.person.id!, dto.active.id);
  }

}