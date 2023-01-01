import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../provider/auth.dart';
import '../provider/product.dart';
import '../Screens/product_datail_screen.dart';
import '../provider/cart.dart';

import 'package:provider/provider.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                  arguments: product.id
                  // MaterialPageRoute(
                  //   builder: (ctx) => P
                  // roductDetailScreen())
                  );
            },
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                image: CachedNetworkImageProvider(
                  product.imageUrl,
                ),
                fit: BoxFit.cover,
              ),
            )),
        footer: GridTileBar(
          leading: Consumer<Product>(
              builder: (ctx, product, _) => IconButton(
                  onPressed: () {
                    product.isFavorites(authData.token, authData.userId);
                  },
                  icon: Icon(product.isFavourite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  color: Theme.of(context).accentColor)),
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Item added to cart!'),
                duration: Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    cart.removeSingleItem(product.id);
                  },
                ),
              ));
            },
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
