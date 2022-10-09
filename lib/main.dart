import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/auth_screen.dart';
import '../screens/splash_screen.dart';
import './screens/product_details_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';

import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProduct) => Products(
              auth.token as String,
              auth.userId,
              previousProduct == null ? [] : previousProduct.items),
          create: (ctx) => Products.def(),
        ),
        ChangeNotifierProvider(create: (ctx) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders('', [], ''),
            update: (ctx, auth, previousOrders) => Orders(
                  auth.token as String,
                  (previousOrders == null) ? [] : previousOrders.orders,
                  auth.userId,
                )),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          title: 'My Shop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          //Login Logic
          //If we have auth data, then we can synchronously check whether we need to render HomeScreen() or not
          //If we don't have auth data, we check for tokens in SharedPreferences. This is slow process, hence we use async await.
          //We make use of FutureBuilder. If the ConnectionStatus is waiting, we return Splash Screen.
          //If the autologin fails, we return AuthScreen. If autologins returns true, we still return AuthScreen.
          //In autoLogin we are calling notifyListeners if the auth details were found, so the build function will be called anyways.
          //LOGIC: Irrespective of the response of autoLogin(), we will return AuthScreen. If it returned true, build was called as autoLogin() calls notifyListeners and in
          //the next build, auth.isAuth will be true.
          home: !auth.isAuth
              ? FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SplashScreen();
                    } else {
                      return AuthScreen();
                    }
                  },
                  future: auth.tryAutoLogin(),
                )
              : const ProductsScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            ProductsScreen.routeName: (ctx) => const ProductsScreen(),
          },
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
      ),
      body: const Center(
        child: Text('Boilerplate code'),
      ),
    );
  }
}
