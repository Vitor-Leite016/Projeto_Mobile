import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {

  void navegarParaTela(BuildContext context, String nomeDaRota) {
    Navigator.pushNamed(context, nomeDaRota);
  }

  Container criarContainer(String text, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      width: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 60),
          SizedBox(height: 8),
          Text(text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Não ficar pobre.com"),
        backgroundColor:const Color(0XFF4CAF50),
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Tutorial avançado de como não ficar pobre 2025 100% atualizado sem vírus",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),
            Container(
              width: 100,
              child: Image.asset("assets/images/logo.png"),
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.only(top: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => navegarParaTela(context, '/lista'),
                    child: criarContainer("Despesas", Colors.red, Icons.calendar_month),
                  ),
                  GestureDetector(
                    onTap: () => navegarParaTela(context, '/creditos'),
                    child: criarContainer("Créditos", Colors.cyan, Icons.group),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
