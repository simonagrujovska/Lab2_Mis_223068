import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import 'recipe_detail_screen.dart';

class MealsScreen extends StatefulWidget {
  final String categoryName;

  MealsScreen({required this.categoryName});

  @override
  _MealsScreenState createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final ApiService apiService = ApiService();
  List<Meal> meals = [];
  List<Meal> filteredMeals = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMeals();
  }

  void loadMeals() async {
    try {
      final data = await apiService.getMealsByCategory(widget.categoryName);
      setState(() {
        meals = data;
        filteredMeals = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void searchMeals(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredMeals = meals;
      });
      return;
    }

    try {
      final data = await apiService.searchMeals(query);
      setState(() {
        filteredMeals = data
            .where((meal) =>
            meals.any((m) => m.idMeal == meal.idMeal))
            .toList();
        if (filteredMeals.isEmpty) {
          filteredMeals = meals
              .where((meal) =>
              meal.strMeal.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      });
    } catch (e) {
      setState(() {
        filteredMeals = meals
            .where((meal) =>
            meal.strMeal.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search meals...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: searchMeals,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredMeals.length,
              itemBuilder: (context, index) {
                final meal = filteredMeals[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(
                          mealId: meal.idMeal,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            meal.strMealThumb,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            meal.strMeal,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
