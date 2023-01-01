import 'package:flutter/material.dart';
import 'package:myshop/Screens/auth_screen.dart.dart';
import 'package:myshop/helpers/custom_route.dart';
import '../provider/auth.dart';
import '../Screens/user_product_screen.dart';
import '../Screens/orders_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        AppBar(
          title: Text('Hello Dear!'),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        ListTile(
          leading: Icon(Icons.shop),
          title: Text('Shop'),
          onTap: () => Navigator.of(context).pushReplacementNamed('/'),
        ),
        Divider(),
        ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(OrderScreen.routeName);
              // Navigator.of(context).pushReplacement(
              //     CustomRoute(builder: (ctx) => OrderScreen()));
            }),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Manage Products'),
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(UserProductScreen.routeName),
        ),
        Divider(),
        ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('LogOut'),
            onTap: () {
              // Navigator.of(context)
              //     .pushReplacementNamed(UserProductScreen.routeName),
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logOut();
            }),
      ],
    ));
  }
}
