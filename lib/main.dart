import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/products_overview_screen.dart';
import './screens/splash_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            update: (_, auth, previousProducts) => Products(
                auth.token,
                previousProducts == null ? [] : previousProducts.items,
                auth.userId),
            create: (_) => Products('', [], ''),
          ),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (_, auth, previousOrders) => Orders(auth.token, auth.userId,
                previousOrders == null ? [] : previousOrders.orders),
            create: (_) => Orders('', '', []),
          ),
        ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Mi tienda',
          theme: ThemeData(
            colorScheme:
              ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                  .copyWith(secondary: Colors.deepOrange),
            fontFamily: 'Lato'),
          home: auth.isAuth
            ? ProductsOverviewScreen()
            : FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (ctx, authResultSnapshot) =>
              authResultSnapshot.connectionState==ConnectionState.waiting
              ? SplashScreen()
              : AuthScreen()
          ),
          routes: {
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            // AuthScreen.routeName: (ctx) => EditProductScreen(),
          }
        )
      )
    );
  }
}
