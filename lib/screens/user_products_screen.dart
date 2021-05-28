import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

import '../widgets/main_drawer.dart';
import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user_products_screen';

  Future<void> _refreshProducts(BuildContext context) {
    return Provider.of<Products>(context, listen: false).getProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(
            context), //will cuase infinite loop if called with provider items in the same build function
        builder: (ctx, snapshotData) {
          if (snapshotData.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: Consumer<Products>(
                builder: (context, products, child) {
                  var items = products.items;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemBuilder: (ctx, i) {
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(items[i].imageUrl),
                              ),
                              title: Text(items[i].title),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.edit,
                                            color:
                                                Theme.of(context).primaryColor),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              EditProductScreen.routeName,
                                              arguments: {'id': items[i].id});
                                        }),
                                    IconButton(
                                        icon: Icon(Icons.delete,
                                            color:
                                                Theme.of(context).errorColor),
                                        onPressed: () async {
                                          try {
                                            await Provider.of<Products>(context,
                                                    listen: false)
                                                .removeProduct(items[i].id);
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                              'Deleting failed',
                                              textAlign: TextAlign.center,
                                            )));
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ),
                            Divider()
                          ],
                        );
                      },
                      itemCount: items.length,
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
