import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text(
          'PresupuestApp',
          style: TextStyle(fontSize: 24), // Puedes ajustar el tamaño del texto según sea necesario
        ),
      ),
    );
  }
}


