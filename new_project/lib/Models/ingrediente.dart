

class Ingredient {
  String name;
  double price;
  double totalQuantity; // Nueva propiedad
  double usedQuantity;
  String selectedOption;

  Ingredient({
    required this.name,
    required this.price,
    required this.totalQuantity,
    required this.usedQuantity,
    required this.selectedOption,
  });

  // ignore: non_constant_identifier_names
  double monto_gastado(){
    double valorPorCantidad = price / totalQuantity;
    return valorPorCantidad * usedQuantity;
  }

  
}
