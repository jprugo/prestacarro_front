import 'dto.dart';

abstract class Handler {
  Handler? _next;

  void set next(Handler next) => _next = next;

  Future<void> handle(Dto dto) async{
    await this.execute(dto);
    if (_next != null)
      _next!.handle(dto);
  }

  Future<void> execute(Dto dto);
}
