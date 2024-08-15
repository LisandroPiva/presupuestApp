import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/link.dart';

class LikedProducts extends StatefulWidget {
  final String userId;

  LikedProducts({required this.userId});

  @override
  // ignore: library_private_types_in_public_api
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
            icon: Icon(Icons.info),
            onPressed: (){  _showInfoDialog(context);
            },
            color: Color(0xffd9ebe9),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
            color: Color(0xffd9ebe9),
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
          content: SizedBox(
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

  void _showInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Información de la aplicación',style: TextStyle(color: Colors.white,fontSize: 17)),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Aplicación creada por:',
              style: TextStyle(fontSize: 15,color: Colors.white),
            ),
            SizedBox(height: 15), // Espacio entre el texto y los botones
            Link(
              uri: Uri.parse('https://github.com/AgustinPlatun'),
              target: LinkTarget.blank,
              builder: (BuildContext context, FollowLink? openLink) {
                return ElevatedButton.icon(
                  icon: FaIcon(
                    FontAwesomeIcons.github,
                    color: Color(0xffd9ebe9), // Color del ícono
                  ),
                  label: Text(
                    'Agustin Platun',
                    style: TextStyle(color: Color(0xffd9ebe9)), // Color del texto
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                    backgroundColor: Color(0xff0e1821), // Fondo del botón
                  ),
                  onPressed: openLink,
                );
              },
            ),
            SizedBox(height: 16), // Espacio entre los botones
            Link(
              uri: Uri.parse('https://github.com/LisandroPiva'),
              target: LinkTarget.blank,
              builder: (BuildContext context, FollowLink? openLink) {
                return ElevatedButton.icon(
                  icon: FaIcon(
                    FontAwesomeIcons.github,
                    color: Color(0xffd9ebe9), // Color del ícono
                  ),
                  label: Text(
                    'Lisandro Piva',
                    style: TextStyle(color: Color(0xffd9ebe9)), // Color del texto
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                    backgroundColor: Color(0xff0e1821), // Fondo del botón
                  ),
                  onPressed: openLink,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cerrar'),
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
  // ignore: library_private_types_in_public_api
  _IngredientListPageState createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage> {
  final TextEditingController _percentageController = TextEditingController();

  double _calculateTotalPrice(List<DocumentSnapshot> ingredients) {
    // ignore: avoid_types_as_parameter_names
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
                                  width: 35, // Cambia el ancho del círculo
                                  height: 35, // Cambia la altura del círculo
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.white, size: 20),
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
}
