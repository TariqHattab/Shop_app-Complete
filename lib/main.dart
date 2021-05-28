import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/splash_screen.dart';

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
          create: (ctx) => Products(),
          update: (context, auth, previousProducts) =>
              previousProducts..updateAuthInfo(auth.token, auth.userId),
        ),
        ChangeNotifierProvider<Cart>(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(),
          update: (ctx, auth, previousOrders) =>
              previousOrders..updateAuthInfo(auth.token, auth.userId),
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
              home: auth.isAuth
                  ? ProductOverviewScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SplashScreen();
                        } else {
                          return AuthScreen();
                        }
                      },
                    ),
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
