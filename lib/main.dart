import 'package:flutter_application_1/screens/home.dart';
import 'package:flutter_application_1/screens/creditos.dart';
import 'package:flutter_application_1/screens/lista.dart';
import 'package:flutter/material.dart';


void main(){
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
      routes: {

        '/creditos': (context) => TelaCreditos(),
        '/lista': (context) => TelaLista(),



      },
  ));
}