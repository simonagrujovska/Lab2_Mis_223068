class MealDetail {
  final String idMeal;
  final String strMeal;
  final String strInstructions;
  final String strMealThumb;
  final String? strYoutube;
  final List<String> ingredients;

  MealDetail({
    required this.idMeal,
    required this.strMeal,
    required this.strInstructions,
    required this.strMealThumb,
    this.strYoutube,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    List<String> ingredientsList = [];
    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredientsList.add('$measure $ingredient'.trim());
      }
    }

    return MealDetail(
      idMeal: json['idMeal'],
      strMeal: json['strMeal'],
      strInstructions: json['strInstructions'],
      strMealThumb: json['strMealThumb'],
      strYoutube: json['strYoutube'],
      ingredients: ingredientsList,
    );
  }
}
