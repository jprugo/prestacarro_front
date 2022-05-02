import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'document_scan.dart';

class Index extends StatelessWidget {
  const Index({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => {
          Alert(
              context: context,
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
                child: Image.asset(
                  'assets/images/logo_cc.jpeg',
                  width: 200,
                  height: 200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
