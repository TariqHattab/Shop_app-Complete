import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = <Product>[];
  String authToken;
  String userId;
  void updateAuthInfo(String token, String newUserId) {
    authToken = token;
    userId = newUserId;
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> getProducts([bool filterByUser = false]) async {
    Map<String, String> filterParams = filterByUser
        ? {
            'orderBy': jsonEncode('creatorId'),
            'equalTo': jsonEncode(userId),
          }
        : {};
    Map<String, String> params = {'auth': authToken, ...filterParams};

    var url = Uri.https('flutter-shop-app-ef724-default-rtdb.firebaseio.com',
        '/products.json', params);
    try {
      final response = await http.get(url);
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        _items = [];
        notifyListeners();
        return;
      }
      var responseFav;
      var favoriteData;
      if (!filterByUser) {
        url = Uri.https('flutter-shop-app-ef724-default-rtdb.firebaseio.com',
            '/userFavorites/$userId.json', params);
        responseFav = await http.get(url);

        favoriteData = jsonDecode(responseFav.body) as Map<String, dynamic>;
        print(responseFav.statusCode);
      }

      List<Product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          imageUrl: prodData['imageUrl'],
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(String productId, Product updatedProduct) async {
    var indexProd = _items.indexWhere((element) => element.id == productId);

    final params = {"auth": authToken};
    final url = Uri.https('flutter-shop-app-ef724-default-rtdb.firebaseio.com',
        '/products/$productId.json', params);

    if (indexProd >= 0) {
      final response = await http.patch(url,
          body: jsonEncode({
            "title": updatedProduct.title,
            "description": updatedProduct.description,
            "price": updatedProduct.price,
            "imageUrl": updatedProduct.imageUrl,
          }));

      _items[indexProd] = updatedProduct;
      notifyListeners();
    } else {
      print('product id not found');
    }
  }

  Future<void> removeProduct(String productId) async {
    final params = {'auth': authToken};
    final url = Uri.https('flutter-shop-app-ef724-default-rtdb.firebaseio.com',
        '/products/$productId.json', params);
    final existingProductIndex =
        _items.indexWhere((prod) => prod.id == productId);

    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    var response = await http.delete(url);

    if (response.statusCode >= 400) {
      //becuase delete function does not throw an error we have to check if the statueCode is error manually
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('deleting faild');
    }

    existingProduct = null;
  }

  Future<void> addProduct(Product newProduct) async {
    final params = {'auth': authToken};
    var url = Uri.https('flutter-shop-app-ef724-default-rtdb.firebaseio.com',
        '/products.json', params);
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'creatorId': userId,
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            'isFavorite': newProduct.isFavorite,
          }));
      final nProduct = Product(
        id: jsonDecode(response.body)['name'],
        title: newProduct.title,
        price: newProduct.price,
        description: newProduct.description,
        imageUrl: newProduct.imageUrl,
      );
      _items.add(nProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
