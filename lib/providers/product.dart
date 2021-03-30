import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleIsFavorite(String token) async {
    isFavorite = !isFavorite;
    notifyListeners();
    final params = {'auth': token};
    final url = Uri.https('flutter-shop-app-ef724-default-rtdb.firebaseio.com',
        '/products/${this.id}.json', params);

    var response =
        await http.patch(url, body: jsonEncode({'isFavorite': isFavorite}));
    if (response.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw HttpException('failed');
    }
  }

  Product copyWith({
    String id,
    String title,
    String description,
    double price,
    String imageUrl,
    bool isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
