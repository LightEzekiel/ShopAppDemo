import 'package:flutter/material.dart';
import '../provider/order.dart';
import '../Widgets/cart_item.dart';
import '../provider/cart.dart' show Cart;
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  static const routName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(children: [
        Card(
          margin: EdgeInsets.all(15),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 20),
                ),
                Spacer(),
                Chip(
                  label: Text(
                    '\$${cart.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                OrderButton(cart: cart),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
            child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: cart.item.length,
          itemBuilder: (ctx, i) {
            return CartItem(
                cart.item.values.toList()[i].id,
                cart.item.keys.toList()[i],
                cart.item.values.toList()[i].title,
                cart.item.values.toList()[i].price,
                cart.item.values.toList()[i].quantity);
          },
        ))
      ]),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: (widget.cart.totalAmount <= 0 || isLoading)
            ? null
            : () async {
                setState(() {
                  isLoading = true;
                });
                await Provider.of<Orders>(context, listen: false).addOrder(
                    widget.cart.item.values.toList(), widget.cart.totalAmount);
                setState(() {
                  isLoading = false;
                });
                widget.cart.clear();
              },
        child: isLoading
            ? CircularProgressIndicator()
            : Text(
                'ORDER NOW',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ));
  }
}
