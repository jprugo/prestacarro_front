import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:prestacarro_front/models/active.dart';
import 'package:prestacarro_front/provider/config_model.dart';
import 'package:provider/provider.dart';

class CarCard extends StatelessWidget {
  final Active? active;

  final VoidCallback onTap;

  const CarCard({Key? key, required this.active, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _model = Provider.of<ConfigModel>(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15))),
        width: 110,
        height: 110,
        child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            onTap: (active!.available) ? onTap : null,
            child: Padding(
              child: Column(
                children: [
                  Text(
                    active!.internalCode,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Padding(
                      child: SvgPicture.file(
                        File(_model.config.iconSelection),
                        semanticsLabel: 'Paw Logo',
                        color: (active!.available) == false
                            ? Colors.red
                            : Colors.green,
                        width: 150,
                        height: 150,
                      ),
                      padding: EdgeInsets.all(10),
                    ),
                  )
                ],
              ),
              padding: EdgeInsets.all(10),
            )),
      ),
    );
  }
}
