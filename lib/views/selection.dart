import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
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

  bool isReleasing = false;
  late var nodeUrls = <String?>[];

  @override
  void initState() {
    super.initState();
    final _model = Provider.of<ConfigModel>(context, listen: false);
    backendBaseUrl = _model.config.backendBaseUrl;
    cameraBaseUrl = _model.config.cameraBaseUrl;

    nodeUrls = [
      _model.config.nodeUrl1,
      _model.config.nodeUrl2,
      _model.config.nodeUrl3
    ];

    future = Future.wait(nodeUrls.map((e) => e != null
        ? makeNodemcuGetActivesRequest('$e/actives')
        : basicFuture()));
  }

  Future<dynamic> basicFuture() async {
    return null;
  }

  // backend request
  Future<bool> createLoanRequest(
      BuildContext context, int? idPerson, int? idActive, String url) async {
    // logic

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
        var result2 =
            await makeLiberationRequest(context, map['id'], idActive, url);
        print(result2 ? "Liberacion exitosa" : "No se pudo liberar vehiculo");
      } catch (exception) {
        print(exception.toString());
      }
      return true;
    } else {
      print(response.reasonPhrase);
      return false;
    }

    // To mock function

    // await Future.delayed(Duration(seconds: 1), () {
    //   print('waiting 2 seconds...');
    // });

    // return true;
  }

  // photo backend
  Future<String?> takePicture(String id) async {
    print('taking picture... [URL]: ${cameraBaseUrl}');
    // flask
    if (cameraBaseUrl == null) return null;

    var request = http.MultipartRequest(
        'POST', Uri.parse('${cameraBaseUrl}/takepicture'));

    request.fields.addAll({'id': id});

    final response = await request.send();

    if (response.statusCode == 201) {
      print('Picture was taken!');
      var result = json.decode(await response.stream.bytesToString());
      print(result['imagePath']);
      return result['imagePath'];
    } else {
      print(response.reasonPhrase);
      return null;
    }
  }

  // nodemcu request
  Future<bool> makeLiberationRequest(
      BuildContext context, int idLoan, int? idActive, String url) async {
    print('[Nodemcu] Making release request for loan $idLoan ...');

    var body = json.encode({
      "idLoan": idLoan,
      "idActive": idActive,
    });

    var headers = {
      'Content-Type': 'application/json',
      'Content-Length': body.length.toString()
    };

    var request = http.Request('POST', Uri.parse('$url/liberate'));
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

    // To mocking functionality
    //return true;
  }

  // nodemcu request
  Future<List> makeNodemcuGetActivesRequest(final String url) async {
    // Logic

    print('Making request to: $url ...');

    var request = http.Request('POST', Uri.parse(url));

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print('Fetched data succesfully!');
        var listOfDicts = jsonDecode(await response.stream.bytesToString());
        return listOfDicts.map((e) => Active.fromJson(e)).toList();
      } else {
        print(response.statusCode);
        throw Exception("Se recibio un codigo inesperado.");
      }
    } catch (exception) {
      return List.empty();
    }

    // To mock functionality

    // var rnd = Random();
    // var number = rnd.nextInt(3);

    // await Future.delayed(Duration(seconds: 1), () {
    //   print('waiting 2 seconds...');
    // });

    // if (number <= 0) {
    //   return [
    //     Active(available: true, id: 1, internalCode: 'C01'),
    //     Active(available: true, id: 2, internalCode: 'C02'),
    //     Active(available: true, id: 3, internalCode: 'C03'),
    //     Active(available: true, id: 4, internalCode: 'C04'),
    //     Active(available: true, id: 5, internalCode: 'C05'),
    //   ];
    // } else if (number == 1) {
    //   return [
    //     Active(available: true, id: 1, internalCode: 'C01'),
    //     Active(available: true, id: 2, internalCode: 'C02'),
    //     Active(available: true, id: 3, internalCode: 'C03'),
    //     Active(available: true, id: 4, internalCode: 'C04'),
    //     Active(available: true, id: 5, internalCode: 'C05'),
    //     Active(available: true, id: 6, internalCode: 'C06'),
    //     Active(available: true, id: 7, internalCode: 'C07'),
    //   ];
    // } else {
    //   return [
    //     Active(available: true, id: 1, internalCode: 'C01'),
    //     Active(available: true, id: 2, internalCode: 'C02'),
    //     Active(available: true, id: 3, internalCode: 'C03'),
    //     Active(available: true, id: 4, internalCode: 'C04'),
    //     Active(available: true, id: 5, internalCode: 'C05'),
    //     Active(available: true, id: 6, internalCode: 'C06'),
    //     Active(available: true, id: 7, internalCode: 'C07'),
    //     Active(available: true, id: 8, internalCode: 'C08'),
    //   ];
    // }
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
                  num totalActives = snapshot.data.fold(0, (previous, current) {
                    num temp = current == null ? 0 : current.length;
                    return previous + temp;
                  });

                  if (totalActives == 0) {
                    // show toast

                    showToast(
                      "Lo sentimos, no hay vehiculos disponibles para prestar.",
                      position: ToastPosition.center,
                      duration: Duration(seconds: 4),
                      backgroundColor: Colors.black.withOpacity(0.8),
                      radius: 15.0,
                      textStyle: const TextStyle(fontSize: 30.0),
                    );

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
                                                        Alert(
                                                            context: context,
                                                            title: "Liberacion",
                                                            style: AlertStyle(
                                                              titleStyle: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            type: AlertType
                                                                .warning,
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
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                              ),
                                                              DialogButton(
                                                                onPressed:
                                                                    () async {
                                                                  setState(() {
                                                                    isReleasing =
                                                                        true;
                                                                  });

                                                                  var imagePath =
                                                                      await takePicture(
                                                                          widget.person.documentNumber ??
                                                                              "");

                                                                  print(
                                                                      imagePath);

                                                                  Navigator.pop(
                                                                      context);

                                                                  await createLoanRequest(
                                                                          context,
                                                                          widget
                                                                              .person
                                                                              .id,
                                                                          a.id,
                                                                          nodeUrls[entry
                                                                              .key]!)
                                                                      .then(
                                                                          (value) {
                                                                    if (value) {
                                                                      Alert(
                                                                          context:
                                                                              context,
                                                                          image: Image
                                                                              .file(
                                                                            File(imagePath!),
                                                                            width:
                                                                                400,
                                                                            height:
                                                                                400,
                                                                          ),
                                                                          style:
                                                                              AlertStyle(
                                                                            titleStyle:
                                                                                TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                          onWillPopActive:
                                                                              true,
                                                                          closeFunction:
                                                                              () {},
                                                                          title:
                                                                              "Liberacion",
                                                                          desc:
                                                                              '¡Listo ${widget.person.fullName}! Tienes 30 segundos para retirar el vehiculo ${a.id}',
                                                                          buttons: []).show();
                                                                      Future.delayed(
                                                                          Duration(
                                                                              seconds: 29),
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pushReplacement(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => Index(),
                                                                            ));
                                                                      });
                                                                    }
                                                                  });
                                                                },
                                                                child: Text(
                                                                  "Si",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                              ),
                                                            ]).show();
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
