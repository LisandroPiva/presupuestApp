import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class History extends StatelessWidget {
  final String userId;

  History({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Historial',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').where('userId', isEqualTo: userId).snapshots(),
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
                title: Text(productName,style: TextStyle(fontSize: 30)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IngredientListPage(productId: product.id),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red,size: 30,),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, product.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
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
                _deleteProduct(context, productId);
              },
              child: Text('Borrar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(BuildContext context, String productId) {
    // Primero, eliminamos todos los ingredientes del producto
    FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .collection('ingredients')
        .get()
        .then((snapshot) {
          final batch = FirebaseFirestore.instance.batch();
          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
          }
          return batch.commit();
        })
        .then((_) {
          // Luego, eliminamos el producto
          return FirebaseFirestore.instance.collection('products').doc(productId).delete();
        })
        .then((_) {
          Navigator.of(context).pop(); // Cierra el diálogo
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto y todos sus ingredientes borrados')));
        })
        .catchError((error) {
          Navigator.of(context).pop(); // Cierra el diálogo
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar producto: $error')));
        });
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
              return Text('Hola soy una pantalla de carga ! 😁');
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
                  'Precio: ${ingredient['price']}\nCantidad total del producto: ${ingredient['totalQuantity']}\nCantidad usada: ${ingredient['usedQuantity']}\nUnidad: ${ingredient['selectedOption']}',
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
                      _deleteIngredient(context, productId, ingredient.id);
                    },
                  ),
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
    }).catchError((error) {
      print("Error al eliminar ingrediente: $error");
    });
  }
}
