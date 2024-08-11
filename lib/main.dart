import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ToDo_App/home_page.dart';
import 'package:ToDo_App/remainder.dart'; // Import the TickBoxPage

void main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox('mybox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor:
            Color(0xffF1E5D1), // Set scaffold background color to white
      ),
    );
  }
}
