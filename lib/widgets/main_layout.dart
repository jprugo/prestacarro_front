import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget? child;

  const MainLayout({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Image.asset(
                'assets/images/pets.jpeg',
                width: 150,
                height: 150,
              ),
            ],
          ),
          Expanded(child: child ?? SizedBox()),
        ],
      ),
    );
  }
}
