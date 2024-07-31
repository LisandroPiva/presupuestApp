import 'package:flutter/material.dart';

class Stats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stats Page'),
      ),
      body: Center(
        child: Text(
          'Estadisticardopolis',
          style: TextStyle(fontSize: 24), // Puedes ajustar el tamaño del texto según sea necesario
        ),
      ),
    );
  }
}
