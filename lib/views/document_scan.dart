import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prestacarro_front/models/person.dart';
import 'package:prestacarro_front/utils/utils.dart';

import 'selection.dart';

import 'package:http/http.dart' as http;

class DocumentScan extends StatefulWidget {
  const DocumentScan({Key? key}) : super(key: key);

  @override
  _DocumentScanState createState() => _DocumentScanState();
}

class _DocumentScanState extends State<DocumentScan> {
  // The node used to request the keyboard focus.
  final FocusNode _focusNode = FocusNode();
  String _chain = "";

  late Person person;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void createPersonRequest(Person person) async {
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('POST', Uri.parse('$backendUrl/persons'));

    request.headers.addAll(headers);

    request.body = jsonEncode(person.toJson());

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201 || response.statusCode == 208) {
      String responseStr = await response.stream.bytesToString();
      person = Person.fromJson(jsonDecode(responseStr));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Selection(
                    person: person,
                  )));
    } else {
      print('\x1B[31m${response.reasonPhrase}\x1B[0m');
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _chain = "1098812425>RUEDA>GOMEZ>JUAN>PABLO>M>19981022";
        var array = _chain.split('>');
        if (array.length == 5 || array.length == 7) {
          Person person = Person(
            // Tiene solo un apellido y un nombre
            documentNumber: array[0], // igual para ambos
            firstName:
                array[array.length == 5 ? 2 : 3], // (7) -> [3] (5) -> [2]
            middleName:
                array.length == 7 ? array[4] : null, // (7) -> [4] (5) -> null
            lastName: array[1], // igual para ambos
            surName:
                array.length == 7 ? array[2] : null, // (7) -> [2] (5) -> null
            birthDate:
                array[array.length == 5 ? 4 : 6], // (7) -> [6] (5) -> [4]
            sex: array[array.length == 5 ? 3 : 5], // (7) -> [5] (5) -> [3]
          );
          createPersonRequest(person);
        } else if (array.length == 6) {
          Person person = Person(
              documentNumber: array[0],
              firstName: array[3],
              lastName: array[1],
              surName: array[2], //'middleName':'Blah'
              birthDate: array[5],
              sex: array[4]);
          createPersonRequest(person);
        }
        //User user =
      } else {
        setState(() {
          _chain += event.logicalKey.keyLabel;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focusNode);
    return Scaffold(
        body: RawKeyboardListener(
            focusNode: _focusNode,
            onKey: _handleKeyEvent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/logo_cc.jpeg',
                        width: 150,
                        height: 150,
                      ),
                      Text(
                        'Sistema de despacho automatizado para mascotas',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Image.asset(
                        'assets/images/pets.jpeg',
                        width: 150,
                        height: 150,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                          child: Container(
                              width: 900,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Image.asset(
                                          'assets/images/document_icon.jpeg',
                                          width: 180,
                                          height: 180,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Escanea tu documento",
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              "Ubica la parte trasera de tu documento en el lector de codigo de barras",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Divider(),
                                    Image.asset(
                                      'assets/images/document.jpeg',
                                      width: 350,
                                      height: 350,
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}
