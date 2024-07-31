import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importa la librería para inputFormatters
import 'package:namer_app/Models/ingrediente.dart'; // Importa el archivo donde está definida la clase Ingredient

class HomePage extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isProductNameSubmitted && !_areIngredientFieldsVisible)
              Center(
                child: Text(
                  'Product Name: $_productName',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            if (!_isProductNameSubmitted)
              Center(
                child: Container(
                  width: 300,
                  child: TextField(
                    controller: _productController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            if (!_isProductNameSubmitted)
              SizedBox(height: 16),
            if (!_isProductNameSubmitted)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _productName = _productController.text;
                      _isProductNameSubmitted = true;
                    });
                  },
                  child: Text('Save Product Name'),
                ),
              ),
            if (_isProductNameSubmitted && !_areIngredientFieldsVisible)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _areIngredientFieldsVisible = true;
                    });
                  },
                  child: Text('Add Ingredients'),
                ),
              ),
            if (_areIngredientFieldsVisible)
              Column(
                children: [
                  SizedBox(height: 16),
                  TextField(
                    controller: _ingredientNameController,
                    decoration: InputDecoration(
                      labelText: 'Ingredient Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _ingredientPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ingredient Price',
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
                      labelText: 'Total Quantity',
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
                      labelText: 'Used Quantity',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: _selectedOption,
                    hint: Text('Select Unit'),
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
                    onPressed: () {
                      setState(() {
                        _ingredients.add(
                          Ingredient(
                            name: _ingredientNameController.text,
                            price: double.tryParse(_ingredientPriceController.text) ?? 0,
                            totalQuantity: double.tryParse(_ingredientTotalQuantityController.text) ?? 0,
                            usedQuantity: double.tryParse(_ingredientUsedQuantityController.text) ?? 0,
                            selectedOption: _selectedOption ?? 'None',
                          ),
                        );
                        _areIngredientFieldsVisible = false;
                        // Limpiar campos y opciones después de guardar
                        _ingredientNameController.clear();
                        _ingredientPriceController.clear();
                        _ingredientTotalQuantityController.clear();
                        _ingredientUsedQuantityController.clear();
                        _selectedOption = null;
                      });
                    },
                    child: Text('Save Ingredient Info'),
                  ),
                  SizedBox(height: 16),
                 ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _areIngredientFieldsVisible = false;
                        // Limpiar campos y opciones al volver al estado anterior
                        _ingredientNameController.clear();
                        _ingredientPriceController.clear();
                        _ingredientTotalQuantityController.clear();
                        _ingredientUsedQuantityController.clear();
                        _selectedOption = null;
                      });
                    },
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // Color de fondo del botón de cancelar
                    ),
                  ),
                ],
              ),
            if (!_areIngredientFieldsVisible && _ingredients.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = _ingredients[index];
                    return ListTile(
                      title: Text(ingredient.name),
                      subtitle: Text(
                        'Price: ${ingredient.price}\nTotal Quantity: ${ingredient.totalQuantity}\nUsed Quantity: ${ingredient.usedQuantity}\nUnit: ${ingredient.selectedOption}',
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
