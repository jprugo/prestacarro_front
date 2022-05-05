import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prestacarro_front/models/active.dart';
import 'package:prestacarro_front/models/person.dart';
import 'package:prestacarro_front/views/index.dart';
import 'package:prestacarro_front/widgets/car_card.dart';

import 'package:http/http.dart' as http;
import 'package:prestacarro_front/widgets/main_layout.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../provider/config_model.dart';

class Selection extends StatefulWidget {
  final Person person;

  const Selection({Key? key, required this.person}) : super(key: key);

  @override
  _SelectionState createState() => _SelectionState();
}

class _SelectionState extends State<Selection> {
  // Future
  late Future<List> future;

  late String? backendBaseUrl;
  late String? cameraBaseUrl;
  late String? node1BaseUrl;
  late String? node2BaseUrl;
  late String? node3BaseUrl;

  bool isReleasing = false;

  @override
  void initState() {
    super.initState();
    final _model = Provider.of<ConfigModel>(context, listen: false);
    backendBaseUrl = _model.config.backendBaseUrl;
    node1BaseUrl = _model.config.nodeUrl1;
    node2BaseUrl = _model.config.nodeUrl2;
    node3BaseUrl = _model.config.nodeUrl3;
    cameraBaseUrl = _model.config.cameraBaseUrl;
    future = Future.wait([
      makeNodemcuGetActivesRequest('$node1BaseUrl/actives'),
      makeNodemcuGetActivesRequest('$node2BaseUrl/actives'),
      makeNodemcuGetActivesRequest('$node3BaseUrl/actives'),
    ]);
  }

  // backend request
  Future<bool> createLoanRequest(
      BuildContext context, int? idPerson, int? idActive) async {
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('POST', Uri.parse('$backendBaseUrl/loans'));

    request.body = json.encode({
      "idPerson": idPerson,
      "idActive": idActive,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      var map = jsonDecode(await response.stream.bytesToString());
      try {
        var result2 = await makeLiberationRequest(context, map['id'], idActive);
        print(result2 ? "Liberacion exitosa" : "No se pudo liberar vehiculo");
      } catch (exception) {
        print(exception.toString());
      }
      return true;
    } else {
      print(response.reasonPhrase);
      return false;
    }
  }

  // photo backend
  Future<bool> takePicture(String id) async {
    // flask
    var request = http.MultipartRequest(
        'POST', Uri.parse('${cameraBaseUrl}/takepicture'));

    request.fields.addAll({'id': id});

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      print('Picture was taken!');
      return true;
    } else {
      print(response.reasonPhrase);
      return false;
    }
  }

  // nodemcu request
  Future<bool> makeLiberationRequest(
      BuildContext context, int idLoan, int? idActive) async {
    // test
    print('[Nodemcu] Making release request for loan $idLoan ...');

    var body = json.encode({
      "idLoan": idLoan,
      "idActive": idActive,
    });

    var headers = {
      'Content-Type': 'application/json',
      'Content-Length': body.length.toString()
    };

    var request = http.Request('POST', Uri.parse('$node1BaseUrl/liberate'));
    request.headers.addAll(headers);
    request.body = body;

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('Dispatched!');
      return true;
    } else {
      print(response.statusCode);
      //throw Exception('Failed!');
      return false;
    }
  }

  // nodemcu request
  Future<List> makeNodemcuGetActivesRequest(final String url) async {
    print('Making request to: $url ...');

    
    var request = http.Request('POST', Uri.parse(url));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('Fetched data succesfully!');
      var listOfDicts = jsonDecode(await response.stream.bytesToString());
      return listOfDicts.map((e) => Active.fromJson(e)).toList();
    } else {
      print(response.statusCode);
      throw Exception('Failed!');
    }

    // Prueba
    /*
    return [
      {
        "id": 1,
        "internal_code": "C01",
        "available": false,
      },
      {
        "id": 2,
        "internal_code": "C02",
        "available": true,
      },
      {
        "id": 3,
        "internal_code": "C03",
        "available": true,
      },
      {
        "id": 4,
        "internal_code": "C04",
        "available": false,
      },
      {
        "id": 5,
        "internal_code": "C05",
        "available": false,
      },
    ].map((e) => Active.fromJson(e)).toList();*/
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
            //future: _testMakeNodemcuGetActivesRequest(8),
            builder: (
              BuildContext context,
              AsyncSnapshot snapshot,
            ) {
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
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  //return Text('OK');
                  return Column(
                    children: [
                      !isReleasing
                          ? Column(
                              children: snapshot.data
                                  .map<Widget>(
                                    (row) => Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: row
                                          .map<Widget>((c) => CarCard(
                                                active: c,
                                                onTap: () {
                                                  Alert(
                                                      context: context,
                                                      title: "Liberacion",
                                                      type: AlertType.warning,
                                                      content: Column(
                                                        children: [
                                                          Text(
                                                              '${widget.person.fullName} ¿Deseas continuar con la operacion?'),
                                                        ],
                                                      ),
                                                      buttons: [
                                                        DialogButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: Text(
                                                            "No",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20),
                                                          ),
                                                        ),
                                                        DialogButton(
                                                          onPressed: () async {
                                                            setState(() {
                                                              isReleasing =
                                                                  true;
                                                            });

                                                            await takePicture(widget
                                                                    .person
                                                                    .documentNumber ??
                                                                "");
                                                            // make request with backend to create loan
                                                            await createLoanRequest(
                                                                    context,
                                                                    widget
                                                                        .person
                                                                        .id,
                                                                    c.id)
                                                                .then((value) {
                                                              if (value) {
                                                                Alert(
                                                                    context:
                                                                        context,
                                                                    onWillPopActive:
                                                                        true,
                                                                    closeFunction:
                                                                        () {},
                                                                    title:
                                                                        "Liberacion",
                                                                    desc:
                                                                        '¡Listo ${widget.person.fullName}! Tienes 30 segundos para retirar el vehiculo ${c.id}',
                                                                    type: AlertType
                                                                        .success,
                                                                    buttons: []).show();
                                                                Future.delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            8),
                                                                    () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                Index(),
                                                                      ));
                                                                });
                                                              }
                                                            });

                                                            Navigator.pop(
                                                                context);

                                                            //Prueba
                                                            /*
                                                    Future.delayed(
                                                        Duration(seconds: 6),
                                                        () {
                                                      Alert(
                                                          context: context,
                                                          onWillPopActive: true,
                                                          closeFunction: () {},
                                                          title: "Liberacion",
                                                          desc:
                                                              '¡Listo ${widget.person.fullName}! Tienes 30 segundos para retirar el vehiculo ${e.id}',
                                                          type:
                                                              AlertType.success,
                                                          buttons: []).show();
                                                      Future.delayed(
                                                          Duration(seconds: 8),
                                                          () {
                                                        Navigator.pop(context);
                                                        Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Index(),
                                                            ));
                                                      });
                                                    });
                                                    */
                                                          },
                                                          child: Text(
                                                            "Si",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20),
                                                          ),
                                                        ),
                                                      ]).show();
                                                },
                                              ))
                                          .toList(),
                                    ),
                                  )
                                  .toList(),
                            )
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
