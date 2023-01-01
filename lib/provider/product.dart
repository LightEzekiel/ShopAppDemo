import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  String id;
  String title;
  String description;
  double price;
  String imageUrl;
  bool isFavourite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavourite = false});

  void setFavValue(bool newValue) {
    isFavourite = newValue;
    notifyListeners();
  }

  Future<void> isFavorites(String? token, String? userId) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url =
        'https://flutter-update-23b95-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      final response =
          await http.put(Uri.parse(url), body: json.encode(isFavourite));
      if (response.statusCode >= 400) {
        setFavValue(oldStatus);
      }
    } catch (error) {
      setFavValue(oldStatus);
    }
  }
}
