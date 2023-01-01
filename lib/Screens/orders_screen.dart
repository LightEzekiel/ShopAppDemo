import 'package:flutter/material.dart';
import '../Widgets/app_drawer.dart';
import '../provider/order.dart' show Orders;
import 'package:provider/provider.dart';
import '../Widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/orders';

  Future<void> _fetchProducts(BuildContext context) async {
    try {
      await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    } catch (error) {
      var errorM = 'Check network connections.';
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
    // final OrderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Order(s)'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _fetchProducts(context),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.error != null) {
                return Center(
                  child: Text('You have not placed any Order yet!.'),
                );
              } else {
                return Consumer<Orders>(
                    builder: (ctx, orderData, child) => ListView.builder(
                          itemCount: orderData.orders.length,
                          itemBuilder: (ctx, i) =>
                              OrderItem(orderData.orders[i]),
                        ));
              }
            }
          },
        )
        // isLoading
        //     ? Center(
        //         child: CircularProgressIndicator(),
        //       )
        //     : ,
        );
  }
}
