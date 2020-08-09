import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screen/splash_scren.dart';
import './providers/auth_provider.dart';
import './screen/atuh_screen.dart';
import './screen/user_products_screen.dart';
import './screen/edit_product_screen.dart';
import './screen/orders_screen.dart';
import './providers/orders_provider.dart';
import './screen/cart_screen.dart';
import './providers/cart_provider.dart';
import './screen/product_detail_screen.dart';
import './screen/products_overview_screen.dart';
import './providers/products_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            update: (context, auth, previousProducts) => Products(
                auth.token,
                auth.userId,
                previousProducts == null ? [] : previousProducts.items),
          ),
          ChangeNotifierProxyProvider<Auth, Cart>(
            update: (context, auth, previousCartItems) => Cart(
                auth.token,
                auth.userId,
                previousCartItems == null ? [] : previousCartItems.items),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (context, auth, previousOrders) => Orders(
                auth.token,
                auth.userId,
                previousOrders == null ? [] : previousOrders.orders),
          ),
        ],
        child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
              title: "My Shop",
              theme: ThemeData(
                primaryColor: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
              ),
              home: auth.isAuth
                  ? ProductOverviewScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLoginMethod(),
                      builder: (context, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen(),
                    ),
              routes: {
                ProductOverviewScreen.routeName: (context) =>
                    ProductOverviewScreen(),
                ProductDetailsScreen.routeName: (context) =>
                    ProductDetailsScreen(),
                CartScreen.routeName: (context) => CartScreen(),
                OrdersScreen.routeName: (context) => OrdersScreen(),
                UserProductsScreen.routeName: (context) => UserProductsScreen(),
                EditProductScreen.routeName: (context) => EditProductScreen(),
              }),
        ));
  }
}
