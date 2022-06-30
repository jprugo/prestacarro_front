import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:prestacarro_front/provider/config_model.dart';
import 'package:prestacarro_front/views/index.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    fullScreen: true,
    
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      // 2-A: wrap your app with OKToast
      textStyle: const TextStyle(fontSize: 19.0, color: Colors.white),
      backgroundColor: Colors.grey,
      radius: 10.0,
      child: MultiProvider(
        providers: [ChangeNotifierProvider(create: (context) => ConfigModel())],
        child: MaterialApp(
          title: 'Prestacarro',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Raleway',
          ),
          //debugShowCheckedModeBanner: false,
          home: Index(),
        ),
      ),
      animationCurve: Curves.easeIn,
      animationDuration: const Duration(milliseconds: 200),
      duration: const Duration(seconds: 3),
    );
  }
}
