import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/main_drawer.dart';
import '../providers/orders.dart';
import '../widgets/order_item.dart' as orderItem;

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders_screen';

  Future<void> _refreshOrders(context) {
    return Provider.of<Orders>(context, listen: false).getOrders();
  }

  @override
  Widget build(BuildContext context) {
    //final ordersObject = Provider.of<Orders>(context);// this cause a loop in build when called with getOrders() since notifyListeners will retrigger ordersObject everyTime
    return Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        body: FutureBuilder(
          future: Provider.of<Orders>(context, listen: false).getOrders(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.error != null) {
              //...
              // Do error handling stuff here.
              return Center(
                child: Text("error occurd in getting orders. "),
              );
            } else {
              return RefreshIndicator(
                onRefresh: () => _refreshOrders(context),
                child: Consumer<Orders>(
                  //have to use Consumer with FutureBuilder to avoid infinit loop
                  builder: (ctx, ordersObject, child) {
                    return ListView.builder(
                      itemBuilder: (ctx, i) {
                        return orderItem.OrderItem(
                            order: ordersObject.orders[i]);
                      },
                      itemCount: ordersObject.orders.length,
                    );
                  },
                ),
              );
            }
          },
        ));
  }
}
