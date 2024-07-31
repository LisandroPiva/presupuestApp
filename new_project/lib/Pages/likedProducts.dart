import 'package:flutter/material.dart';

class Likedproducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Likedproducts Page'),
      ),
      body: Center(
        child: Text(
          'Lista de likeados',
          style: TextStyle(fontSize: 24), // Puedes ajustar el tamaño del texto según sea necesario
        ),
      ),
    );
  }
}
