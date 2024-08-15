import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:namer_app/Pages/history.dart';
import 'package:namer_app/Pages/home.dart';
import 'package:namer_app/Pages/liked_products.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<String> userIdFuture;
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    userIdFuture = _getOrCreateUserId();
    _pages = [];
  }

  Future<String> _getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('user_id');
    
    if (storedUserId != null) {
      return storedUserId;
    } else {
      final newUserId = Uuid().v4();
      await prefs.setString('user_id', newUserId);
      return newUserId;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    // Aquí puedes decidir si quieres que se cierre la aplicación o no
    // Retorna true para permitir el retroceso, o false para bloquearlo
    // Por ejemplo, puedes mostrar un diálogo de confirmación aquí:
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('¿Quieres salir de PresupuestApp?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Sí'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: userIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final userId = snapshot.data!;

          if (_pages.isEmpty) {
            _pages = [
              HomePage(userId: userId),
              History(userId: userId),
              LikedProducts(userId: userId),
            ];
          }

          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              body: _pages[_selectedIndex],
              bottomNavigationBar: SizedBox(
                height: 60,
                child: BarraNavegacion(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  _onItemTapped(0);
                },
                backgroundColor: _selectedIndex == 0 ? Color(0xff06114B) : Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                child: Icon(
                  FontAwesomeIcons.houseChimney, 
                  color: _selectedIndex == 0 ? Color(0xffd9ebe9) : Colors.black
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              resizeToAvoidBottomInset: false,
            ),
          );
        } else {
          return Center(child: Text('No data'));
        }
      },
    );
  }
}

class BarraNavegacion extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  BarraNavegacion({required this.selectedIndex, required this.onItemTapped});

  Widget _bottomAction(BuildContext context, IconData icon, int index) {
    bool isSelected = index == selectedIndex;
    return IconButton(
      iconSize: 30,
      icon: FaIcon(
        icon, 
        color: isSelected ? Colors.blue : Colors.grey
      ),
      onPressed: () {
        onItemTapped(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff798f8c),
      child: SizedBox(
        height: kBottomNavigationBarHeight,
        child: BottomAppBar(
          notchMargin: 8.0,
          color: Color(0xff0e1821),
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _bottomAction(context, FontAwesomeIcons.addressBook, 1),
              SizedBox(width: 48),
              _bottomAction(context, FontAwesomeIcons.solidHeart, 2),
            ],
          ),
        ),
      ),
    );
  }
}
