import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:prestacarro_front/widgets/main_layout.dart';

class Release extends StatefulWidget {
  final Person person;

  const Release({Key? key, required this.person}) : super(key: key);

  @override
  _SelectionState createState() => _SelectionState();
}

// with WidgetsBindingObserver
class _SelectionState extends State<Release> {
  // Control
  bool isReleasing = false;

  Duration myDuration = Duration(minutes: 2);
  Timer? countdownTimer;

  late BackendHandler backendHandler;
  late ActiveGateway activeGateway;

  // Opts
  late String nodeUrl;
  late bool selectionMenuEnabled;

  late Future<Active> future;
  late Active active;
  late ConfigModel _model;

  // State methods
  @override
  void initState() {
    super.initState();

    _model = Provider.of<ConfigModel>(context, listen: false);
    nodeUrl = _model.config.nodes[0];
    selectionMenuEnabled = _model.config.selectionMenuEnabled;

    // Gateways
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

    future = Future.delayed(Duration(seconds: 2), () {
      return stationGateway.getActive(nodeUrl);
    });

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
                          'Despachando...',
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
                if (snapshot.hasData) {
                  active = snapshot.data;
                  return Column(
                    children: [
                      Text(
                        '${widget.person.fullName} ¿Deseas continuar con la operacion?',
                        style: TextStyle(fontSize: 45),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'No',
                              style: TextStyle(fontSize: 35),
                            ),
                          ),
                          SizedBox(width: 16), // Espacio entre los botones
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isReleasing = true;
                              });

                              Dto dto = new Dto(
                                person: widget.person,
                                active: active,
                                stationUrl: nodeUrl,
                              );

                              // TO DO: Logica de
                              await backendHandler.handle(dto);

                              if (dto.released == true) {
                                var image_resource;
                                if (dto.filePath.isEmpty){
                                  image_resource =Image.file(
                                      File(dto.filePath),
                                      width: 400,
                                      height: 400,
                                    );
                                }else{
                                  image_resource =Image.asset(
                                      'assets/images/avatar.jpg',
                                      width: 400,
                                      height: 400,
                                    );
                                }
                                
                                Alert(
                                    context: context,
                                    image: image_resource,
                                    style: AlertStyle(
                                      titleStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onWillPopActive: true,
                                    closeFunction: () {},
                                    title: "Liberacion",
                                    desc:
                                        '¡Listo ${widget.person.fullName}! Tienes 30 segundos para retirar el vehiculo ${active.id}',
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
                            child: Text('Si', style: TextStyle(fontSize: 35)),
                          ),
                        ],
                      )
                    ],
                  );
                }
                return Text('Error en conexión con la estación');
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
