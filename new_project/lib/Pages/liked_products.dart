import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LikedProducts extends StatelessWidget {
  final String userId;

  LikedProducts({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos Favoritos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('userId', isEqualTo: userId)
            .where('liked', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final productName = product['name'];
              return ListTile(
                title: Text(productName, style: TextStyle(fontSize: 24)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IngredientListPage(productId: product.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class IngredientListPage extends StatelessWidget {
  final String productId;

  IngredientListPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('products').doc(productId).get(),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').doc(productId).collection('ingredients').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final ingredients = snapshot.data!.docs;
          return ListView.builder(
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              return ListTile(
                title: Text(ingredient['name']),
                subtitle: Text(
                  'Precio: ${ingredient['price']}\nCantidad total: ${ingredient['totalQuantity']}\nCantidad usada: ${ingredient['usedQuantity']}\nUnidad: ${ingredient['selectedOption']}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteIngredient(context, productId, ingredient.id);
                  },
                ),
              );
            },
          );
        },
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ingrediente borrado')));
        })
        .catchError((error) {
          print("Error al eliminar ingrediente: $error");
        });
  }
}
