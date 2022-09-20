import 'package:allshare/data/app_states.dart';
import 'package:allshare/data/app_data.dart';
import 'package:allshare/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ALLSHARE',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}
