import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  const OrderItem({Key key, this.order}) : super(key: key);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
            title: Text('\$${widget.order.totalAmount.toStringAsFixed(2)}'),
            subtitle:
                Text(DateFormat('dd/MM/yyyy hh:mm').format(widget.order.date)),
          ),
          AnimatedContainer(
              duration: Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: _expanded
                  ? min(widget.order.products.length * 25.0 + 10, 100)
                  : 0,
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: widget.order.products
                    .map(
                      (product) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${product.quantity}x \$${product.price}',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    )
                    .toList(),
              )),
        ],
      ),
    );
  }
}
