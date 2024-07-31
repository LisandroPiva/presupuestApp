import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:namer_app/Pages/history.dart';
import 'package:namer_app/Pages/home.dart';
import 'package:namer_app/Pages/settings.dart';
import 'package:namer_app/Pages/likedProducts.dart';
import 'package:namer_app/Pages/stats.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PresupuestApp',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    History(),
    Likedproducts(),
    Settings(),
    Stats(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BarraNavegacion(
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onItemTapped(0);
        },
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: Icon(FontAwesomeIcons.houseChimney, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class BarraNavegacion extends StatelessWidget {
  final ValueChanged<int> onItemTapped;

  BarraNavegacion({required this.onItemTapped});

  Widget _bottomAction(BuildContext context, IconData icon, int index) {
    return IconButton(
      icon: FaIcon(icon),
      onPressed: () {
        onItemTapped(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      notchMargin: 8.0,
      shape: CircularNotchedRectangle(),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _bottomAction(context, FontAwesomeIcons.chartPie, 4),
          _bottomAction(context, FontAwesomeIcons.solidAddressBook, 1),
          SizedBox(width: 48,), // Espacio para el FloatingActionButton
          _bottomAction(context, FontAwesomeIcons.solidHeart, 2),
          _bottomAction(context, FontAwesomeIcons.gear, 3),
        ],
      ),
    );
  }
}
