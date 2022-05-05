import 'package:flutter/material.dart';
import 'package:prestacarro_front/provider/config_model.dart';
import 'package:prestacarro_front/views/index.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ConfigModel())
      ],
      child: MaterialApp(
        title: 'Prestacarro',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Raleway',
        ),
        //debugShowCheckedModeBanner: false,
        home: Index(),
      ),
    );
  }
}
