import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:namer_app/conectate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter demo',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {


  Widget _bottomAction(IconData icon){
      return InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon),
        ),
        onTap: () {},
      );
  }

  @override
  Widget build(BuildContext context){
return Scaffold(
    body: FutureBuilder(
      future: getCosas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Mostrar un indicador de carga mientras se espera el resultado
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Mostrar un mensaje de error si ocurre un error
        } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay datos disponibles')); // Mostrar un mensaje si no hay datos
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var item = snapshot.data?[index];
              var nombre = item?['nombre'] ?? 'Nombre no disponible'; // Proporcionar un valor predeterminado si 'nombre' es nulo
              var precio = item?['precio'].toString() ?? 'Precio no disponible';
              return ListTile(
                title: Text(nombre),
                subtitle: Text(precio),
              );
            },
          );
        }
      },
    ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _bottomAction(FontAwesomeIcons.chartPie),

            _bottomAction(FontAwesomeIcons.solidAddressBook),
            SizedBox(width: 48,),
            _bottomAction(FontAwesomeIcons.solidHeart),
            _bottomAction(FontAwesomeIcons.gear),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: Icon(FontAwesomeIcons.houseChimney ,color: Colors.black),
      ),
    );
  }

}