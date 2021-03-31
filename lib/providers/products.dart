import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; //used 'as' here to group all functionalities imported from http packege in 'http.' prefix
import 'package:shop_app/models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = <Product>[
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
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
    print(authToken);
    Map<String, String> filterParams = filterByUser
        ? {
            'orderBy': jsonEncode('creatorId'),
            'equalTo': jsonEncode(userId),
          }
        : {};
    Map<String, String> params = {'auth': authToken, ...filterParams};
    print(params);
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

  // void addExistingItems() {
  //   var url = Uri.https(
  //       'flutter-shop-app-ef724-default-rtdb.firebaseio.com', '/products.json');
  //   for (var i in _items) {
  //     http.post(url,
  //         body: jsonEncode({
  //           'title': i.title,
  //           'description': i.description,
  //           'price': i.price,
  //           'imageUrl': i.imageUrl,
  //           'isFavorite': i.isFavorite,
  //         }));
  //   }
  //   print('sent');
  // }

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
      print(response.body);
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
