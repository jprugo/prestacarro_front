import 'dart:io';

import 'package:flutter/material.dart';
import 'package:prestacarro_front/provider/config_model.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatelessWidget {
  final Widget? child;

  const MainLayout({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final _model = Provider.of<ConfigModel>(context, listen: false);

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
              Image.file(
                File(_model.config.logoPath),
                width: 150,
                height: 150,
              ),
              Text(
                _model.config.title,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(_model.config.logo2),
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
