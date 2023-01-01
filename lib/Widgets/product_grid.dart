import 'package:flutter/material.dart';
import './product_item.dart';
import '../provider/products.dart';
import 'package:provider/provider.dart';

class ProductGrid extends StatelessWidget {
  bool showFavs;

  ProductGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products =
        showFavs ? productData.filterFavoriteItem : productData.item;
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
          value: products[i], child: ProductItem()),
      itemCount: products.length,
    );
  }
}
