import 'package:flutter/material.dart';

class History extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Page'),
      ),
      body: Center(
        child: Text(
          'Historial de presupuestados',
          style: TextStyle(fontSize: 24), // Puedes ajustar el tamaño del texto según sea necesario
        ),
      ),
    );
  }
}



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home Page'),
//       ),
//       body: FutureBuilder(
//         future: getCosas(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator()); // Mostrar un indicador de carga mientras se espera el resultado
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}')); // Mostrar un mensaje de error si ocurre un error
//           } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
//             return Center(child: Text('No hay datos disponibles')); // Mostrar un mensaje si no hay datos
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 var item = snapshot.data?[index];
//                 var nombre = item?['nombre'] ?? 'Nombre no disponible'; // Proporcionar un valor predeterminado si 'nombre' es nulo
//                 var precio = item?['precio'].toString() ?? 'Precio no disponible';
//                 return ListTile(
//                   title: Text(nombre),
//                   subtitle: Text(precio),
//                 );
//               },
//             );
//           }
//         },
//       ),
//       bottomNavigationBar: BarraNavegacion(
//         onFabPressed: () {
//           Acciones para el FloatingActionButton
//         },
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Acciones para el FloatingActionButton
//         },
//         backgroundColor: Colors.blue,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
//         child: Icon(FontAwesomeIcons.houseChimney, color: Colors.black),
//       ),
//     );
//   }
// }