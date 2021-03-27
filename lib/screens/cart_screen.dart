import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../providers/cart.dart';
import '../widgets/cart_item_card.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart_screen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
        appBar: AppBar(title: Text('the Cart')),
        body: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Total'),
                    Spacer(),
                    Chip(
                      backgroundColor: Theme.of(context).primaryColor,
                      label: Text(
                        "\$${cart.itemsAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .headline6
                                .color),
                      ),
                    ),
                    OrderButton(cart: cart)
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (ctx, i) => CartItemCard(
                  id: cart.items.values.toList()[i].id,
                  productId: cart.items.keys.toList()[i],
                  title: cart.items.values.toList()[i].title,
                  price: cart.items.values.toList()[i].price,
                  quantity: cart.items.values.toList()[i].quantity,
                ),
                itemCount: cart.items.length,
              ),
            )
          ],
        ));
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(child: CircularProgressIndicator()),
          )
        : TextButton(
            child: Text(
              "ORDER NOW",
              //style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onPressed: widget.cart.itemsAmount <= 0
                ? null
                : () {
                    setState(() {
                      _isLoading = true;
                    });
                    Provider.of<Orders>(context, listen: false)
                        .addOrder(
                            products: widget.cart.items.values.toList(),
                            total: widget.cart.itemsAmount)
                        .then((value) {
                      Future.delayed(Duration(seconds: 3)).then((value) {
                        print('in then');
                        setState(() {
                          _isLoading = false;
                        });
                      });
                    });
                    widget.cart.clear();
                  },
          );
  }
}
