import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prestacarro_front/models/active.dart';
import 'package:prestacarro_front/models/person.dart';
import 'package:prestacarro_front/utils/utils.dart';
import 'package:prestacarro_front/widgets/car_card.dart';

import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'index.dart';

class Selection extends StatefulWidget {
  final Person person;

  const Selection({Key? key, required this.person}) : super(key: key);

  @override
  _SelectionState createState() => _SelectionState();
}

class _SelectionState extends State<Selection> {
  // Future
  late Future<List> future;

  bool isReleasing = false;

  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    future = Future.wait([
      makeNodemcuGetActivesRequest('$nodeUrl/actives'),
    ]);
  }

  // backend request
  Future<bool> createLoanRequest(
      BuildContext context, int? idPerson, int? idActive) async {
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('POST', Uri.parse('$backendUrl/loans'));

    request.body = json.encode({
      "idPerson": idPerson,
      "idActive": idActive,
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    setState(() {
      isReleasing = true;
    });

    if (response.statusCode == 201) {
      var map = jsonDecode(await response.stream.bytesToString());
      try {
        var result2 = await makeLiberationRequest(context, map['id'], idActive);
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
  Future<bool> takePicture(String name) async {
    // flask
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:5000/takepicture'));

    request.fields.addAll({'name': name});

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

    var request = http.Request('POST', Uri.parse('$nodeUrl/liberate'));
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
      return listOfDicts.map((e) => idActive.fromJson(e)).toList();
    } else {
      print(response.statusCode);
      throw Exception('Failed!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: snapshot.data[0]
                            .map<Widget>((e) => CarCard(
                                  active: e,
                                  onTap: () {
                                    Alert(
                                        context: context,
                                        title: "Liberacion",
                                        type: AlertType.info,
                                        content: Column(
                                          children: [
                                            Text(
                                                '${widget.person.fullName} ¿Deseas continuar con la operacion?'),
                                          ],
                                        ),
                                        buttons: [
                                          DialogButton(
                                            onPressed: !isReleasing
                                                ? () => Navigator.pop(context)
                                                : null,
                                            child: Text(
                                              "No",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          DialogButton(
                                            onPressed: !isReleasing
                                                ? () async {
                                                    print('click!');
                                                    /*await takePicture(widget
                                                            .person.fullName ??
                                                        "");*/
                                                    // make request with backend to create loan
                                                    await createLoanRequest(
                                                        context,
                                                        widget.person.id,
                                                        e.id);

                                                    print('fin click!');
                                                    Navigator.pop(context);

                                                    Alert(
                                                      context: context,
                                                      title: "Liberacion",
                                                      desc:
                                                          '¡Listo ${widget.person.fullName}! Tienes 30 segundos para retirar el vehiculo ${e.id}',
                                                      type: AlertType.info,
                                                    ).show();
                                                    Future.delayed(
                                                        Duration(seconds: 30),
                                                        () {
                                                      Navigator.pop(context);
                                                    }).whenComplete(() {
                                                      // navigate to index :)
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Index()));
                                                    });
                                                  }
                                                : null,
                                            child: Text(
                                              "Si",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ]).show();
                                  },
                                ))
                            .toList(),
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
    );
  }
}
