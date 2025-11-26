import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import 'meals_screen.dart';
import 'recipe_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiService apiService = ApiService();
  List<Category> categories = [];
  List<Category> filteredCategories = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    try {
      final data = await apiService.getCategories();
      setState(() {
        categories = data;
        filteredCategories = data;
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

  void filterCategories(String query) {
    setState(() {
      filteredCategories = categories
          .where((cat) => cat.strCategory.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void showRandomRecipe() async {
    try {
      final meal = await apiService.getRandomMeal();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailScreen(mealId: meal.idMeal),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Categories'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle),
            onPressed: showRandomRecipe,
            tooltip: 'Random Recipe',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: filterCategories,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final category = filteredCategories[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: ListTile(
                    leading: Image.network(
                      category.strCategoryThumb,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      category.strCategory,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      category.strCategoryDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MealsScreen(
                            categoryName: category.strCategory,
                          ),
                        ),
                      );
                    },
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
