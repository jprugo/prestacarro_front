import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:prestacarro_front/models/active.dart';

class CarCard extends StatelessWidget {
  final idActive? active;

  final VoidCallback onTap;

  const CarCard({Key? key, this.active, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30))),
        width: 150,
        height: 150,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          onTap: (active!.available ?? false) ? onTap : null,
          child: Column(
            children: [
              Text(
                active!.internalCode ?? "N/A",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Padding(
                  child: SvgPicture.asset(
                    'assets/svgs/paw.svg',
                    semanticsLabel: 'Paw Logo',
                    color: (active!.available ?? false) == false
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
        ),
      ),
    );
  }
}