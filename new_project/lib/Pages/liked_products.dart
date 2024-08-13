import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LikedProducts extends StatefulWidget {
  final String userId;

  LikedProducts({required this.userId});

  @override
  _LikedProductsState createState() => _LikedProductsState();
}

class _LikedProductsState extends State<LikedProducts> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0e1821),
        title: Text(
          'Productos Favoritos',
          style: TextStyle(color: Color(0xffd9ebe9)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Container(
        color: Color(0xff798f8c), // Color de fondo del body
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('userId', isEqualTo: widget.userId)
              .where('liked', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final products = snapshot.data!.docs.where((doc) {
              final productName = doc['name'].toString().toLowerCase();
              return productName.contains(_searchQuery.toLowerCase());
            }).toList();

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final productName = product['name'];
                return Container(
                  // Padding a los costados
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), // Margen entre los elementos
                  decoration: BoxDecoration(
                    color: Color(0xff44535E), // Fondo azul para cada elemento de la lista
                    borderRadius: BorderRadius.circular(12.0), // Borde redondeado
                  ),
                  child: ListTile(
                    title: Text(
                      productName,
                      style: TextStyle(fontSize: 30, color: Colors.white), // Color del texto
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: () {
                        _unlikeProduct(context, product.id);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IngredientListPage(productId: product.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _unlikeProduct(BuildContext context, String productId) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({'liked': false})
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto desmarcado de favoritos')));
        })
        .catchError((error) {
          print("Error al desmarcar el producto: $error");
        });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buscar producto'),
          content: Container(
            width: double.maxFinite,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ingrese el nombre del producto',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _searchQuery = _searchController.text;
                });
              },
              child: Text('Buscar'),
            ),
          ],
        );
      },
    );
  }
}

class IngredientListPage extends StatefulWidget {
  final String productId;

  IngredientListPage({required this.productId});

  @override
  _IngredientListPageState createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage> {
  final TextEditingController _percentageController = TextEditingController();

  double _calculateTotalPrice(List<DocumentSnapshot> ingredients) {
    return ingredients.fold(0.0, (sum, ingredient) {
      final price = ingredient['price'] / ingredient['totalQuantity'] * ingredient['usedQuantity']?.toDouble() ?? 0.0;
      return sum + price;
    });
  }

  double _calculateTotalPriceWithProfit(double totalBasePrice, double percentage) {
    return totalBasePrice + (totalBasePrice * percentage / 100);
  }

  double _calculateGanancia(double precioConGanancia, double precioSinGanancia) {
    return precioConGanancia - precioSinGanancia;
  }

  void _deleteIngredient(BuildContext context, String productId, String ingredientId) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .collection('ingredients')
        .doc(ingredientId)
        .delete()
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ingrediente borrado')));
        })
        .catchError((error) {
          print("Error al eliminar ingrediente: $error");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('products').doc(widget.productId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Cargando...');
            }
            if (snapshot.hasError) {
              return Text('Error');
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('Producto no encontrado');
            }
            final productData = snapshot.data!.data() as Map<String, dynamic>;
            final productName = productData['name'] ?? 'Producto sin nombre';
            return Text('Ingredientes de $productName');
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _percentageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ingrese el porcentaje de ganancia',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').doc(widget.productId).collection('ingredients').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final ingredients = snapshot.data!.docs;
                final totalBasePrice = _calculateTotalPrice(ingredients);
                final percentage = double.tryParse(_percentageController.text) ?? 0.0;
                final totalPriceWithProfit = _calculateTotalPriceWithProfit(totalBasePrice, percentage);
                final ganancia = _calculateGanancia(totalPriceWithProfit, totalBasePrice);

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = ingredients[index];
                          return ListTile(
                            title: Text(ingredient['name']),
                            subtitle: Text(
                              'Precio: ${ingredient['price']}\nCantidad total: ${ingredient['totalQuantity']}\nCantidad usada: ${ingredient['usedQuantity']}\nUnidad: ${ingredient['selectedOption']}',
                            ),
                            isThreeLine: true,
                            trailing: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  _deleteIngredient(context, widget.productId, ingredient.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Precio Total sin ganancia: \$${totalBasePrice.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Precio Total con ganancia: \$${totalPriceWithProfit.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ganancia: \$${ganancia.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
