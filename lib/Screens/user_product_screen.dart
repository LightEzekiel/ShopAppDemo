import 'package:flutter/material.dart';
import 'package:myshop/models/http_exception.dart';
import '../Screens/edit_product_screen.dart';
import '../Widgets/app_drawer.dart';
import '../Widgets/user_product_item.dart';
import 'package:provider/provider.dart';
import '../provider/products.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProduct(BuildContext context) async {
    try {
      await Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts(true);
    } on HttpException catch (error) {
      var errorMessage = 'Poor network state!';
      _showErrorDialog(errorMessage, context);
    } catch (error) {
      var errorM = 'Check your network connection!';
      _showErrorDialog(errorM, context);
    }
  }

  void _showErrorDialog(String message, BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Network Error'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(), child: Text('OK'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreens.routeName);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProduct(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProduct(context),
                    child: Consumer<Products>(
                      builder: (ctx, productData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                            itemCount: productData.item.length,
                            itemBuilder: (_, i) {
                              return Column(
                                children: [
                                  UserProductItem(
                                      productData.item[i].id,
                                      productData.item[i].title,
                                      productData.item[i].imageUrl),
                                  Divider(
                                    thickness: 2.5,
                                  ),
                                ],
                              );
                            }),
                      ),
                    ),
                  ),
      ),
    );
  }
}
