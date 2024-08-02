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
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<String> userIdFuture; // Para almacenar el ID del usuario
  int _selectedIndex = 0;

  late List<Widget> _pages; // Define la lista de páginas

  @override
  void initState() {
    super.initState();
    userIdFuture = _getOrCreateUserId(); // Obtén el ID del usuario al iniciar
    _pages = []; // Inicializa _pages como una lista vacía
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

          // Inicializa _pages solo si no ha sido inicializado
          if (_pages.isEmpty) {
            _pages = [
              HomePage(userId: userId),
              History(userId: userId),
              LikedProducts(userId: userId),
              //Settings(),
              //Stats(),
            ];
          }

          return Scaffold(
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
              backgroundColor: _selectedIndex == 0 ? Colors.blue : Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              child: Icon(
                FontAwesomeIcons.houseChimney, 
                color: _selectedIndex == 0 ? Colors.black : Colors.white
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            resizeToAvoidBottomInset: false,
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
    return BottomAppBar(
      notchMargin: 8.0,
      shape: CircularNotchedRectangle(),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          //_bottomAction(context, FontAwesomeIcons.chartPie, 4),
          _bottomAction(context, FontAwesomeIcons.addressBook, 1),
          SizedBox(width: 48,),
          _bottomAction(context, FontAwesomeIcons.solidHeart, 2),
          //_bottomAction(context, FontAwesomeIcons.gear, 3),
        ],
      ),
    );
  }
}
