import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/Models/ingrediente.dart';

class HomePage extends StatefulWidget {
  final String userId;

  HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _ingredientNameController = TextEditingController();
  final TextEditingController _ingredientPriceController = TextEditingController();
  final TextEditingController _ingredientTotalQuantityController = TextEditingController();
  final TextEditingController _ingredientUsedQuantityController = TextEditingController();

  String _productName = '';
  bool _isProductNameSubmitted = false;
  bool _areIngredientFieldsVisible = false;
  List<Ingredient> _ingredients = [];
  String? _selectedOption;
  final List<String> _options = ['gramos', 'mililitros', 'unidades'];
  String? _productId; // Variable para almacenar el ID del producto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: _isProductNameSubmitted && !_areIngredientFieldsVisible
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Nombre de producto: $_productName',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _areIngredientFieldsVisible = true;
                          });
                        },
                        child: Text('Agregar ingrediente'),
                      ),
                      if (_ingredients.isNotEmpty)
                        ...[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12), // Bordes redondeados para el contenedor principal
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.0),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: Offset(0, 2), // Cambia el offset según sea necesario
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: 550, // Ajusta la altura según sea necesario
                              child: ListView.builder(
                                padding: EdgeInsets.all(8.0), // Añade un poco de padding interno
                                itemCount: _ingredients.length,
                                itemBuilder: (context, index) {
                                  final ingredient = _ingredients[index];
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 4.0), // Espacio entre los elementos
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 192, 152, 145), // Fondo azul para cada elemento
                                      borderRadius: BorderRadius.circular(8), // Bordes redondeados para los elementos
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0, 1), // Cambia el offset según sea necesario
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(12.0), // Espacio interno del ListTile
                                      title: Text(
                                        ingredient.name,
                                        style: TextStyle(color: Color.fromARGB(255, 42, 8, 0)), // Texto en blanco para mejor contraste
                                      ),
                                      subtitle: Text(
                                        'Precio: ${ingredient.price}\nCantidad total: ${ingredient.totalQuantity}\nCantidad usada: ${ingredient.usedQuantity}\nUnidad: ${ingredient.selectedOption}',
                                        style: TextStyle(color: Color.fromARGB(255, 42, 8, 0)), // Texto en blanco con opacidad
                                      ),
                                      isThreeLine: true,
                                      trailing: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.delete, color: Colors.white),
                                          onPressed: () => _deleteIngredient(index),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!_isProductNameSubmitted)
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: _productController,
                            decoration: InputDecoration(
                              labelText: 'Nombre de producto',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      if (!_isProductNameSubmitted)
                        SizedBox(height: 16),
                      if (!_isProductNameSubmitted)
                        ElevatedButton(
                          onPressed: _saveProduct,
                          child: Text('Guardar'),
                        ),
                      if (_areIngredientFieldsVisible)
                        ...[
                          SizedBox(height: 16),
                          TextField(
                            controller: _ingredientNameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre de ingrediente',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _ingredientPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Precio de ingrediente',
                              border: OutlineInputBorder(),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _ingredientTotalQuantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Cantidad total',
                              border: OutlineInputBorder(),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _ingredientUsedQuantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Cantidad usada',
                              border: OutlineInputBorder(),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          SizedBox(height: 16),
                          DropdownButton<String>(
                            value: _selectedOption,
                            hint: Text('Seleccionar unidad de medida'),
                            items: _options.map((String option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedOption = newValue;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addIngredientToFirestore,
                            child: Text('Guardar'),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _areIngredientFieldsVisible = false;
                                _ingredientNameController.clear();
                                _ingredientPriceController.clear();
                                _ingredientTotalQuantityController.clear();
                                _ingredientUsedQuantityController.clear();
                                _selectedOption = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: Text('Cancelar'),
                          ),
                        ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _saveProduct() async {
    setState(() {
      _productName = _productController.text;
      _isProductNameSubmitted = true;
    });

    // Guardar producto y obtener su ID
    DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc();
    _productId = productRef.id;

    await productRef.set({
      'name': _productName,
      'userId': widget.userId,
      'liked': false, // Inicializar el campo 'liked' en false
    }).catchError((error) {
      print("Fallo al añadir producto: $error");
    });
  }

  void _addIngredientToFirestore() async {
    if (_productId == null) {
      print("Producto no encontrado");
      return;
    }

    final ingredient = Ingredient(
      name: _ingredientNameController.text,
      price: double.tryParse(_ingredientPriceController.text) ?? 0,
      totalQuantity: double.tryParse(_ingredientTotalQuantityController.text) ?? 0,
      usedQuantity: double.tryParse(_ingredientUsedQuantityController.text) ?? 0,
      selectedOption: _selectedOption ?? 'None',
    );

    FirebaseFirestore.instance.collection('products').doc(_productId).collection('ingredients').add({
      'name': ingredient.name,
      'price': ingredient.price,
      'totalQuantity': ingredient.totalQuantity,
      'usedQuantity': ingredient.usedQuantity,
      'selectedOption': ingredient.selectedOption,
    }).then((docRef) {
      setState(() {
        _ingredients.add(ingredient);
        _areIngredientFieldsVisible = false;
        _ingredientNameController.clear();
        _ingredientPriceController.clear();
        _ingredientTotalQuantityController.clear();
        _ingredientUsedQuantityController.clear();
        _selectedOption = null;
      });
    }).catchError((error) {
      print("Fallo al añadir ingrediente: $error");
    });
  }

  void _deleteIngredient(int index) {
    final ingredient = _ingredients[index];
    FirebaseFirestore.instance
      .collection('products')
      .doc(_productId)
      .collection('ingredients')
      .where('name', isEqualTo: ingredient.name)
      .get()
      .then((ingredientSnapshot) {
        for (DocumentSnapshot doc in ingredientSnapshot.docs) {
          doc.reference.delete();
        }
        setState(() {
          _ingredients.removeAt(index);
        });
      }).catchError((error) {
        print("Error al eliminar el ingrediente: $error");
      });
  }
}
