import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'document_scan.dart';

class Index extends StatefulWidget {
  const Index({Key? key}) : super(key: key);

  @override
  State<Index> createState() => _IndexState();
}

const imagesFolderPath =
    r"C:\PrestaCarroDesktop\images";

class _IndexState extends State<Index> {
  // variables
  late Timer timer;
  late Future future;
  var count = 0;
  var currentImagePath = null;

  @override
  void initState() {
    super.initState();
    future = dirContents(Directory(imagesFolderPath));
    future.then((output) {
      changeImageSlideShow(output);
      /*timer = Timer.periodic(
          Duration(seconds: 10), (Timer timer) => changeImageSlideShow(output));*/
    });
  }

  
  @override
  void dispose() {
    super.dispose();
  }

  changeImageSlideShow(List<FileSystemEntity> output) {
    print('changing image');
    if (count <= output.length - 1) {
      setState(() {
        currentImagePath = output[count].path;
        count++;
      });
    } else {
      count = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => {
          Alert(
              context: context,
              type: AlertType.info,
              title: "Terminos y condiciones",
              desc:
                  "Al continuar aceptas nuestros terminos y condiciones, los cuales encontraras en la pagina www.caciquecc.com",
              //image: Image.asset("assets/success.png"),
              buttons: [
                DialogButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DocumentScan()));
                  },
                  child: Text(
                    "Aceptar",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ]).show()
        },
        child: Container(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: FutureBuilder(
                  future: future,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return  CircularProgressIndicator();
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return const Text('Error');
                      } else if (snapshot.hasData) {
                        return Image.file(
                          File(currentImagePath),
                          height: 45.0,
                          width: 45.0,
                        );
                      } else {
                        return const Text('No hay data que mostrar');
                      }
                    } else {
                      return Text('State: ${snapshot.connectionState}');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<FileSystemEntity>> dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen((file) => files.add(file),
        // should also register onError
        onDone: () => completer.complete(files));
    return completer.future;
  }
}
