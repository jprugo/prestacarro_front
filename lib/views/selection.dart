import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:prestacarro_front/chain/backend_handler.dart';
import 'package:prestacarro_front/chain/camera_handler.dart';
import 'package:prestacarro_front/chain/dto.dart';
import 'package:prestacarro_front/chain/station_handler.dart';
import 'package:prestacarro_front/gateway/active_gateway.dart';
import 'package:prestacarro_front/gateway/camera_gateway.dart';
import 'package:prestacarro_front/gateway/loan_gateway.dart';
import 'package:prestacarro_front/gateway/station_gateway.dart';
import 'package:provider/provider.dart';

import 'package:rflutter_alert/rflutter_alert.dart';

import '../models/active.dart';
import '../provider/config_model.dart';
import 'package:prestacarro_front/models/person.dart';
import 'package:prestacarro_front/views/index.dart';
import 'package:prestacarro_front/widgets/car_card.dart';
import 'package:prestacarro_front/widgets/main_layout.dart';

class Selection extends StatefulWidget {
  final Person person;

  const Selection({Key? key, required this.person}) : super(key: key);

  @override
  _SelectionState createState() => _SelectionState();
}

// with WidgetsBindingObserver
class _SelectionState extends State<Selection> {
  bool isReleasing = false;
  Duration myDuration = Duration(minutes: 2);

  Timer? countdownTimer;

  late BackendHandler backendHandler;

  late Future<List> future;
  late var nodeUrls = <String>[];
  late bool selectionMenuEnabled;

  late ActiveGateway activeGateway;
  late ConfigModel _model;

  // State methods
  @override
  void initState() {
    super.initState();
    _model = Provider.of<ConfigModel>(context, listen: false);
    nodeUrls = _model.config.nodes;
    selectionMenuEnabled = _model.config.selectionMenuEnabled;

    StationGateway stationGateway = new StationGateway();
    CameraGateway cameraGateway =
        new CameraGateway(_model.config.cameraBaseUrl);
    LoanGateway loanGateway = new LoanGateway(_model.config.backendBaseUrl);
    activeGateway = new ActiveGateway(_model.config.backendBaseUrl);

    // Chain of responsability
    backendHandler = new BackendHandler(loanGateway);
    CameraHandler cameraHandler = new CameraHandler(cameraGateway);
    StationHandler stationHandler = new StationHandler(stationGateway);

    backendHandler.next = stationHandler;
    stationHandler.next = cameraHandler;

    future = Future.wait(nodeUrls.map((e) => stationGateway.getActives(e)));

    startTimer();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
        if (!isReleasing) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Index()));
        }
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  Alert getReleaseAlert(BuildContext context, Active a, String stationUrl) {
    return Alert(
        context: context,
        title: "Liberacion",
        style: AlertStyle(
          titleStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        type: AlertType.warning,
        content: Column(
          children: [
            Text(
                '${widget.person.fullName} ¿Deseas continuar con la operacion?'),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "No",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            onPressed: () async {
              //Cierre de boton
              Navigator.pop(context);

              setState(() {
                isReleasing = true;
              });

              Dto dto = new Dto(
                person: widget.person,
                active: a,
                stationUrl: stationUrl,
              );

              // TO DO: Logica de
              await backendHandler.handle(dto);

              if (dto.released == true) {
                var image_resource;
                if (!dto.filePath.isEmpty){
                  image_resource =Image.file(
                      File(dto.filePath),
                      width: 400,
                      height: 400,
                    );
                }else{
                  image_resource =Image.file(
                      File(_model.config.avatar),
                      width: 400,
                      height: 400,
                  );
                }
                Alert(
                    context: context,
                    image: image_resource,
                    style: AlertStyle(
                      titleStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onWillPopActive: true,
                    closeFunction: () {},
                    title: "Liberacion",
                    desc:
                        '¡Listo ${widget.person.fullName}! Tienes 30 segundos para retirar el vehiculo ${a.id}',
                    buttons: []).show();
                Future.delayed(Duration(seconds: 29), () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Index(),
                      ));
                });
                setState(() {
                  isReleasing = false;
                });
              } else {
                print("no pudo ser liberado");
              }
            },
            child: Text(
              "Si",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MainLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          FutureBuilder(
            future: future,
            builder: (
              BuildContext context,
              AsyncSnapshot snapshot,
            ) {
              // Show progress bar while obtains availables actives in nodes
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          child: CircularProgressIndicator(
                            strokeWidth: 10,
                          ),
                          width: 60,
                          height: 60,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Obteniendo informacion de las plazas.',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w300),
                        )
                      ],
                    )
                  ],
                );
              }
              // Node's response obtained
              else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  num totalActives = snapshot.data.fold(0, (previous, current) {
                    num temp = current == null
                        ? 0
                        : current.where((e) => e.available == true).length;
                    return previous + temp;
                  });

                  if (totalActives == 0) {
                    showToast(
                      "Lo sentimos, no hay vehiculos disponibles para prestar.",
                      position: ToastPosition.center,
                      duration: Duration(seconds: 4),
                      backgroundColor: Colors.red.withOpacity(0.8),
                      radius: 15.0,
                      textStyle: const TextStyle(fontSize: 30.0),
                    );

                    // Luego de mostrar el toast nos devolvemos :(
                    Future.delayed(Duration(seconds: 4), () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Index(),
                          ));
                    });
                  }

                  var data = snapshot.data.asMap();

                  return Column(
                    children: [
                      !isReleasing
                          ? Column(
                              children: data.entries
                                  .map<Widget>((entry) => Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: entry.value != null
                                            ? entry.value
                                                .map<Widget>((a) => CarCard(
                                                      active: a,
                                                      onTap: () {
                                                        getReleaseAlert(
                                                                context,
                                                                a,
                                                                nodeUrls[
                                                                    entry.key])
                                                            .show();
                                                      },
                                                    ))
                                                .toList()
                                            : [
                                                Text(
                                                    'No se puede mostrar estacion')
                                              ],
                                      ))
                                  .toList())
                          : Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Estamos procesando la solicitud, un momento por favor.',
                                  style: TextStyle(fontSize: 18),
                                )
                              ],
                            ),
                    ],
                  );
                } else {
                  return const Text('No hay data que mostrar');
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            },
          )
        ],
      ),
    ));
  }
}
