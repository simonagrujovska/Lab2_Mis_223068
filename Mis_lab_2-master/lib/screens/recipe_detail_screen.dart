import 'package:flutter/material.dart';
import '../models/meal_detail.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String mealId;

  RecipeDetailScreen({required this.mealId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final ApiService apiService = ApiService();
  MealDetail? mealDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMealDetail();
  }

  void loadMealDetail() async {
    try {
      final data = await apiService.getMealDetail(widget.mealId);
      setState(() {
        mealDetail = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details'),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              mealDetail!.strMealThumb,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealDetail!.strMeal,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ingredients:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...mealDetail!.ingredients.map((ingredient) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $ingredient'),
                  )),
                  SizedBox(height: 16),
                  Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    mealDetail!.strInstructions,
                    style: TextStyle(fontSize: 14),
                  ),
                  if (mealDetail!.strYoutube != null &&
                      mealDetail!.strYoutube!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = mealDetail!.strYoutube!;
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                        icon: Icon(Icons.play_arrow),
                        label: Text('Watch on YouTube'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
