import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './screens/auth_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/orders_screen.dart';
import './providers/orders.dart';
import './providers/cart.dart';
import './providers/products.dart';
import './screens/cart_screen.dart';
import './screens/poduct_detail_screen.dart';
import './screens/product_overview_screen.dart';
import './screens/user_products_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: null,
          update: (context, auth, previousProducts) => Products(
            auth.token,
            previousProducts.items == null
                ? []
                : previousProducts
                    .items, //so the previous instance items are not lost with the new instatyation
          ),
        ),
        ChangeNotifierProvider<Cart>(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: null,
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            previousOrders.orders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'MyShop',
              theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
              ),
              home: auth.isAuth ? ProductOverviewScreen() : AuthScreen(),
              routes: {
                ProductDetailsScreen.routeName: (ctx) => ProductDetailsScreen(),
                CartScreen.routeName: (ctx) => CartScreen(),
                OrdersScreen.routeName: (ctx) => OrdersScreen(),
                UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                EditProductScreen.routeName: (ctx) => EditProductScreen(),
              });
        },
      ),
    );
  }
}

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('MyShop'),
//       ),
//       body: Center(
//         child: Text('Let\'s build a shop!'),
//       ),
//     );
//   }
// }
