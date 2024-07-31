import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings Page'),
      ),
      body: Center(
        child: Text(
          'Configuracion (no tengo idea de que se puede configurar)',
          style: TextStyle(fontSize: 24), // Puedes ajustar el tamaño del texto según sea necesario
        ),
      ),
    );
  }
}
