import 'package:cloud_firestore/cloud_firestore.dart';
  
  
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List> getCosas()async {
    List cosas = [];
    CollectionReference collectionReferenceCosas = db.collection('Ingredientes');

    QuerySnapshot queryCosas = await collectionReferenceCosas.get();
    queryCosas.docs.forEach((documento) {
      cosas.add(documento.data());
    });
    return cosas;
  }