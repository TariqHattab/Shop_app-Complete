import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product_details';

  @override
  Widget build(BuildContext context) {
    String productId = ModalRoute.of(context).settings.arguments as String;
    var loadedProduct = Provider.of<Products>(context).findById(productId);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text(loadedProduct.title),
                background: LayoutBuilder(
                  builder: (ctx, constraints) {
                    return Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        Container(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                          child: Hero(
                            tag: loadedProduct.id,
                            child: Image.network(
                              loadedProduct.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.black26,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight * .2,
                        )
                      ],
                    );
                  },
                )),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Text(
              '\$${loadedProduct.price}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                '${loadedProduct.description}',
                style: TextStyle(),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 800,
            )
          ]))
        ],
      ),
    );
  }
}
