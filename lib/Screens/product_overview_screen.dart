import 'package:flutter/material.dart';
import '../Screens/cart_screen.dart';
import '../Widgets/app_drawer.dart';
import '../Widgets/badge.dart';
import '../Widgets/product_grid.dart';
import 'package:provider/provider.dart';
import '../provider/cart.dart';
import '../provider/products.dart';

enum filterOptions {
  favorite,
  all,
}

class ProductOverViewScreen extends StatefulWidget {
  @override
  State<ProductOverViewScreen> createState() => _ProductOverViewScreenState();
}

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {
  var _showOnlyFavorite = false;

  var _isInit = true;
  var isLoading = false;

  @override
  void initState() {
    // Provider.of<Products>(context, listen: false).fetchAndSetProducts();

    // Future.delayed(Duration.zero).then((_) {
    // Provider.of<Products>(context, listen: false).fetchAndSetProducts();
    // });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        isLoading = true;
      });
    }
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .catchError((error) {
      print(error);
    }).then((_) {
      setState(() {
        isLoading = false;
      });
    });
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text('Shop'),
          actions: [
            PopupMenuButton(
                onSelected: ((filterOptions selected) {
                  setState(() {
                    switch (selected) {
                      case filterOptions.favorite:
                        // productContainer.showFavoriteOnly();
                        _showOnlyFavorite = true;
                        break;
                      case filterOptions.all:
                        // productContainer.showAll();
                        _showOnlyFavorite = false;
                        break;
                    }
                  });
                  // print(selected);
                }),
                icon: Icon(Icons.more_vert),
                itemBuilder: ((context) => [
                      PopupMenuItem(
                        child: Text('Only favorite'),
                        value: filterOptions.favorite,
                      ),
                      PopupMenuItem(
                        child: Text('Show all'),
                        value: filterOptions.all,
                      ),
                    ])),
            Consumer<Cart>(
              builder: (_, cart, ch) => cart.itemCount == 0
                  ? Container()
                  : Badge(child: ch!, value: cart.itemCount.toString()),
              child: IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(CartScreen.routName),
                icon: Icon(Icons.shopping_cart),
              ),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ProductGrid(_showOnlyFavorite));
  }
}
