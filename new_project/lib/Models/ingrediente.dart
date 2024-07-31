// ingredient.dart

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

  double monto_gastado(){
    double valor_por_cantidad = price / totalQuantity;
    return valor_por_cantidad * usedQuantity;
  }

}
