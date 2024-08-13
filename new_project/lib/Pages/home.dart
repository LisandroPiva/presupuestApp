import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/Models/ingrediente.dart';

class HomePage extends StatefulWidget {
  final String userId;

  HomePage({required this.userId});

  @override
  // ignore: library_private_types_in_public_api
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

  double get _totalPrice {
    // ignore: avoid_types_as_parameter_names
    return _ingredients.fold(0, (sum, ingredient) => sum + ingredient.price);
  }

  double get _totalUsedPrice {
    // ignore: avoid_types_as_parameter_names
    return _ingredients.fold(0, (sum, ingredient) {
      final unitPrice = ingredient.price / ingredient.totalQuantity; // Precio por unidad
      return sum + (unitPrice * ingredient.usedQuantity); // Costo de la cantidad usada
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff44535e), // Fondo de toda la pantalla
      appBar: AppBar(
        title: Text(
          'Home Page',
          style: TextStyle(color: Color(0xffd9ebe9)), // Color del texto en el AppBar
        ),
        backgroundColor: Color(0xff0e1821),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xffd9ebe9), // Color del icono en el AppBar
          ),
          onPressed: () {
            // Verifica que se pueda hacer pop
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // En caso de que no se pueda hacer pop, navega a una pantalla específica
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
      ),
      body: Container(
        color: Color(0xff798f8c), // Color de fondo del body
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 150), // Ajusta este valor para cambiar la distancia desde la parte superior
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: _isProductNameSubmitted && !_areIngredientFieldsVisible
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Nombre de producto: $_productName',
                                style:TextStyle(fontSize: 20),
                                selectionColor: Color(0xffd9ebe9),
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
                                      height: 450, // Ajusta la altura según sea necesario
                                      child: ListView.builder(
                                        padding: EdgeInsets.all(8.0), // Añade un poco de padding interno
                                        itemCount: _ingredients.length,
                                        itemBuilder: (context, index) {
                                          final ingredient = _ingredients[index];
                                          return Container(
                                            margin: EdgeInsets.symmetric(vertical: 4.0), // Espacio entre los elementos
                                            decoration: BoxDecoration(
                                              color: Color(0xff44535e), // Fondo azul para cada elemento
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
                                                style: TextStyle(color: Color(0xffd9ebe9)), // TITULO 
                                              ),
                                              subtitle: Text(
                                                'Precio: ${ingredient.price}\nCantidad total: ${ingredient.totalQuantity}\nCantidad usada: ${ingredient.usedQuantity}\nUnidad: ${ingredient.selectedOption}',
                                                style: TextStyle(color: Color(0xffd9ebe9)), // Texto en blanco con opacidad
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
                                  // Mostrar el precio total y el precio usado aquí
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Precio total: \$${_totalPrice.toStringAsFixed(2)}',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Gastado en ingredientes usados: \$${_totalUsedPrice.toStringAsFixed(2)}',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
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
                                    cursorColor: Color(0xffd9ebe9), // Color del cursor
                                    style: TextStyle(color: Color(0xffd9ebe9)), // Color del texto
                                    decoration: InputDecoration(
                                      labelText: 'Nombre de producto',
                                      labelStyle: TextStyle(color: Color(0xffd9ebe9)), // Color del texto de la etiqueta
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xffd9ebe9), // Color del borde cuando el campo está habilitado
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xffd9ebe9), // Color del borde cuando el campo está enfocado
                                        ),
                                      ),
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
                                      cursorColor: Color(0xffd9ebe9), // Color del cursor
                                      style: TextStyle(color: Color(0xffd9ebe9)), // Color del texto
                                      controller: _ingredientNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Nombre de ingrediente',
                                        labelStyle: TextStyle(color: Color(0xffd9ebe9)), // Color del texto de la etiqueta
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xffd9ebe9), // Color del borde cuando el campo está habilitado
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xffd9ebe9), // Color del borde cuando el campo está enfocado
                                          ),
                                        ),
                                      ),
                                    ),

                                  SizedBox(height: 16),
                                    TextField(
                                      controller: _ingredientPriceController,
                                      keyboardType: TextInputType.number,
                                      cursorColor: Color(0xffd9ebe9), // Color del cursor
                                      style: TextStyle(color: Color(0xffd9ebe9)), // Color del texto
                                      decoration: InputDecoration(
                                        labelText: 'Precio de ingrediente',
                                        labelStyle: TextStyle(color: Color(0xffd9ebe9)), // Color del texto de la etiqueta
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xffd9ebe9), // Color del borde cuando el campo está habilitado
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xffd9ebe9), // Color del borde cuando el campo está enfocado
                                          ),
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),

                                 SizedBox(height: 16),
                                    TextField(
                                      controller: _ingredientTotalQuantityController,
                                      keyboardType: TextInputType.number,
                                      cursorColor: Color(0xffd9ebe9), // Color del cursor
                                      style: TextStyle(color: Color(0xffd9ebe9)), // Color del texto
                                      decoration: InputDecoration(
                                        labelText: 'Cantidad total',
                                        labelStyle: TextStyle(color: Color(0xffd9ebe9)), // Color del texto de la etiqueta
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xffd9ebe9), // Color del borde cuando el campo está habilitado
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xffd9ebe9), // Color del borde cuando el campo está enfocado
                                          ),
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),

                                  SizedBox(height: 16),
                                    TextField(
                                      controller: _ingredientUsedQuantityController,
                                      keyboardType: TextInputType.number,
                                      cursorColor: Color(0xffd9ebe9), // Color del cursor
                                      style: TextStyle(color: Color(0xffd9ebe9)), // Color del texto
                                      decoration: InputDecoration(
                                        labelText: 'Cantidad usada',
                                        labelStyle: TextStyle(color: Color(0xffd9ebe9)), // Color del texto de la etiqueta
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xffd9ebe9), // Color del borde cuando el campo está habilitado
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xffd9ebe9), // Color del borde cuando el campo está enfocado
                                          ),
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),

                                  SizedBox(height: 16),
                                    DropdownButton<String>(
                                      value: _selectedOption,
                                      hint: Text(
                                        'Seleccionar unidad de medida',
                                        style: TextStyle(color: Color(0xffd9ebe9)), // Color del texto del hint
                                      ),
                                      items: _options.map((String option) {
                                        return DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(
                                            option,
                                            style: TextStyle(color: Color(0xffd9ebe9)), // Color del texto de cada opción
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedOption = newValue;
                                        });
                                      },
                                      dropdownColor: Color(0xff0e1821), // Color de fondo del menú desplegable
                                      iconEnabledColor: Color(0xffd9ebe9), // Color del ícono de la flecha
                                      iconDisabledColor: Color(0xffd9ebe9), // Color del ícono de la flecha cuando está deshabilitado
                                    ),

                                  SizedBox(height: 16),
                                  ElevatedButton(
                                        onPressed: _addIngredientToFirestore,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xff06114B), // Color de fondo del botón
                                        ).copyWith(
                                          foregroundColor: WidgetStateProperty.all(Color(0xffd9ebe9)), // Color del texto del botón
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del botón al contenido
                                          children: [
                                            Icon(Icons.add, color: Color(0xffd9ebe9)), // Ícono de "+" con el color especificado
                                            SizedBox(width: 2), // Espacio entre el ícono y el texto
                                            Text('Guardar'), // Texto del botón
                                          ],
                                        ),
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
                                          backgroundColor: Colors.red, // Color de fondo del botón
                                        ).copyWith(
                                          foregroundColor: WidgetStateProperty.all(Color(0xffd9ebe9)), // Color del texto del botón
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del botón al contenido
                                          children: [
                                            Icon(Icons.delete, color: Color(0xffd9ebe9)), // Ícono de tacho de basura con el color especificado
                                            SizedBox(width: 8), // Espacio entre el ícono y el texto
                                            Text('Cancelar'), // Texto del botón
                                          ],
                                        ),
                                      ),
                                ],
                            ],
                          ),
                  ),
                ),
              ),
            ],
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
