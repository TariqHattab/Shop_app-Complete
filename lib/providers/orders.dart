import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/cart.dart';

class OrderItem {
  final String id;
  final List<CartItem> products;
  final double totalAmount;
  final DateTime date;

  OrderItem(
      {@required this.id,
      @required this.products,
      @required this.totalAmount,
      @required this.date});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;

  Orders(this.authToken, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder({List<CartItem> products, double total}) async {
    var dateNow = DateTime.now();

    final params = {'auth': authToken};
    var url = Uri.https('flutter-shop-app-ef724-default-rtdb.firebaseio.com',
        '/orders.json', params);
    try {
      var response = await http.post(url,
          body: jsonEncode({
            "products": products.map((e) {
              return {
                'id': e.id,
                'price': e.price,
                'title': e.title,
                'quantity': e.quantity,
              };
            }).toList(),
            "totalAmount": total,
            "date": dateNow
                .toIso8601String(), //so it can be converted back from json easily.
          }));

      _orders.insert(
        0,
        OrderItem(
          id: jsonDecode(response.body)['name'],
          products: products,
          totalAmount: total,
          date: dateNow,
        ),
      );
      notifyListeners();
    } catch (e) {
      _orders.removeAt(0);
      print('post order failed');
      print(e);
      notifyListeners();
    }
  }

  Future<void> getOrders() async {
    final params = {'auth': authToken};
    var url = Uri.https('flutter-shop-app-ef724-default-rtdb.firebaseio.com',
        '/orders.json', params);
    List<OrderItem> loadedOrders = [];
    var response = await http.get(url);
    var ordersData = jsonDecode(response.body) as Map<String, dynamic>;
    if (ordersData == null) {
      _orders = [];
      notifyListeners();
      return;
    }
    ordersData.forEach((ordId, ordData) {
      loadedOrders.add(OrderItem(
        id: ordId,
        products: (ordData['products'] as List<dynamic>).map((e) {
          return CartItem(
            id: e['id'],
            price: e['price'],
            title: e['title'],
            quantity: e['quantity'],
          );
        }).toList(),
        totalAmount: ordData['totalAmount'],
        date: DateTime.parse(ordData['date']),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
