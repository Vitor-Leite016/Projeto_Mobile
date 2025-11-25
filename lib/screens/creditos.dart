import 'package:flutter/material.dart';

class TelaCreditos extends StatefulWidget {
  const TelaCreditos({super.key});
  
  @override
  TelaCreditosState createState() => TelaCreditosState();
}

class TelaCreditosState extends State<TelaCreditos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Créditos"),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.group, color: Colors.pink, size: 60),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text("Créditos",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.pink
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 32),
              Center(
                child: Column(
                  children: <Widget>[
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        Container(
                          width: 300.0,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            
                            children: <Widget>[
                            Icon( Icons.boy , color: Colors.blue, size: 60),
                            Text("Vitor Leite", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                            Wrap(
                              children: <Widget>[
                                Text("lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus imperdiet, nulla et dictum interdum, nisi lorem egestas odio, vitae scelerisque enim ligula venenatis dolor. Maecenas nisl est, ultrices nec congue eget, auctor vitae massa." , style: TextStyle( )),
                              ],
                            )
                            
                            ],
                            
                          ),
                        ),
                        SizedBox(width: 50),
                        Container(
                          width: 300.0,
                          child: Column(
                            
                            children: <Widget>[
                            Icon( Icons.boy , color: Colors.green, size: 60),
                            Text("José Luan" , style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                            Wrap(
                              children: <Widget>[
                                Text("lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus imperdiet, nulla et dictum interdum, nisi lorem egestas odio, vitae scelerisque enim ligula venenatis dolor. Maecenas nisl est, ultrices nec congue eget, auctor vitae massa." , style: TextStyle( )),
                              ],
                            )
                            
                            ],
                            
                          ),
                        ),
                        SizedBox(width: 50),
                        
                      ]
                    )
                    
                    // Implementar a lista de clientes

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}