import 'package:flutter/material.dart';
import './helpers/custom_route.dart';
import './Screens/splash_screen.dart.dart';
import './provider/auth.dart';
import './Screens/edit_product_screen.dart';
import './Screens/user_product_screen.dart';
import './Screens/orders_screen.dart';
import './provider/order.dart';
import './Screens/cart_screen.dart';
import './provider/cart.dart';
import './provider/products.dart';
import './Screens/product_datail_screen.dart';
import './Screens/auth_screen.dart.dart';
import './Screens/product_overview_screen.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products(),
            update: (ctx, auth, previousProduct) =>
                previousProduct!..update(auth.token, auth.userId),
            //  Products(auth.token!,
            //     previousProduct!.item.isEmpty ? [] : previousProduct.item),
          ),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders(),
            update: (ctx, auth, authToken) =>
                authToken!..update(auth.token, auth.userId),
            // value: Orders(),
          )
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shops',
            home: auth.isAuth
                ? ProductOverViewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder(),
                })),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routName: (ctx) => CartScreen(),
              OrderScreen.routeName: (ctx) => OrderScreen(),
              UserProductScreen.routeName: (ctx) => UserProductScreen(),
              EditProductScreens.routeName: (ctx) => EditProductScreens(),
              // AuthScreen.routeName: (ctx) => AuthScreen()
            },
          ),
        ));
  }
}
