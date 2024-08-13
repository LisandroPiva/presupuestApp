import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class History extends StatefulWidget {
  final String userId;

  History({required this.userId});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buscar producto'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 150,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ingrese el nombre del producto',
                    border: OutlineInputBorder(),
                  ),
                ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Historial',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xffd9ebe9)),
          ),
        ),
        backgroundColor: Color(0xff0e1821),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Container(
        color: Color(0xff798f8c),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('userId', isEqualTo: widget.userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final products = snapshot.data!.docs.where((product) {
              final productName = (product.data() as Map<String, dynamic>)['name']?.toLowerCase() ?? '';
              return productName.contains(_searchQuery.toLowerCase());
            }).toList();

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final productData = product.data() as Map<String, dynamic>?;
                final productName = productData?['name'] ?? 'Producto sin nombre';
                final liked = productData != null && productData.containsKey('liked') ? productData['liked'] : false;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0xff44535E),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    title: Text(
                      productName,
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            color: liked ? Color(0xffFF4760) : Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            _toggleLike(product.id, liked);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Color(0xff19222d),
                            size: 30,
                          ),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, product.id);
                          },
                        ),
                      ],
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

  void _toggleLike(String productId, bool isLiked) {
    FirebaseFirestore.instance.collection('products').doc(productId).update({
      'liked': !isLiked,
    }).catchError((error) {
      print("Error al actualizar el estado de 'like': $error");
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Advertencia'),
          content: Text('¿Estás seguro de que quieres eliminar el producto y todos sus ingredientes?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(context, productId);
              },
              child: Text('Borrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    try {
      // Primero, eliminamos todos los ingredientes del producto
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('ingredients')
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      // Luego, eliminamos el producto
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto y todos sus ingredientes borrados')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar producto: $error')));
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('products')
              .doc(widget.productId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Cargando...');
            }
            if (snapshot.hasError) {
              return Text('Error');
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('No hay productos');
            }
            final productData = snapshot.data!.data() as Map<String, dynamic>;
            final productName = productData['name'] ?? 'Producto sin nombre';
            return Text('Ingredientes de $productName');
          },
        ),
        backgroundColor: Color(0xff0e1821),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: Color(0xff798f8c),
        child: Column(
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
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
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
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.productId)
                    .collection('ingredients')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final ingredients = snapshot.data!.docs;
                  final totalBasePrice = _calculateTotalPrice(ingredients);
                  final percentage =
                      double.tryParse(_percentageController.text) ?? 0.0;
                  final totalPriceWithProfit =
                      _calculateTotalPriceWithProfit(totalBasePrice, percentage);
                  final ganancia =
                      _calculateGanancia(totalPriceWithProfit, totalBasePrice);

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: ingredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = ingredients[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Color(0xff56716F),
                                border: Border.all(
                                  color: Color(0xffA7BFBC),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                title: Text(
                                  ingredient['name'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Costo: ${ingredient['price']}\nCantidad total del producto: ${ingredient['totalQuantity']}\nCantidad usada: ${ingredient['usedQuantity']}\nUnidad: ${ingredient['selectedOption']}',
                                  style: TextStyle(color: Colors.white),
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
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Color(0xff44535E),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(5, 4),
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Precio Tot. gastado sin ganancia: \$${totalBasePrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Precio Tot. con ganancia: \$${totalPriceWithProfit.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Ganancia: \$${ganancia.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteIngredient(BuildContext context, String productId, String ingredientId) {
    FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .collection('ingredients')
        .doc(ingredientId)
        .delete()
        .then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ingrediente borrado')));
      }
    }).catchError((error) {
      print("Error al eliminar ingrediente: $error");
    });
  }
}
