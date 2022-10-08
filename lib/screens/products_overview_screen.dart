import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/cart_screen.dart';

import '../widgets/badge.dart';
import '../widgets/product_item.dart';
import '../widgets/app_drawer.dart';

import '../providers/cart.dart';
import '../providers/products.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsScreen extends StatefulWidget {
  static const routeName = '/products-screen';
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _showFavoritesOnly = false;
  bool _isInit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts()
          .catchError((error) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Fetching failed'),
            content: Text(error.toString()),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              )
            ],
          ),
        );
      }).then((_) => setState(() {
                _isLoading = false;
              }));
    }
    _isInit = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Consumer<Cart>(
            builder: (ctx, cart, child) => Badge(
                value: cart.itemcount.toString(),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  },
                )),
          ),
          PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (FilterOptions selectedValue) {
                switch (selectedValue) {
                  case FilterOptions.all:
                    {
                      setState(() {
                        _showFavoritesOnly = false;
                      });
                      break;
                    }
                  case FilterOptions.favorites:
                    {
                      setState(() {
                        _showFavoritesOnly = true;
                      });
                      break;
                    }
                }
              },
              itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: FilterOptions.favorites,
                      child: Text('Only Favorites'),
                    ),
                    const PopupMenuItem(
                      value: FilterOptions.all,
                      child: Text('Show All'),
                    ),
                  ]),
        ],
      ),
      drawer: const AppDrawer(),
      body: (_isLoading)
          ? const Center(child: CircularProgressIndicator())
          : ProductsGrid(_showFavoritesOnly),
    );
  }
}

class ProductsGrid extends StatelessWidget {
  final bool _showFavoritesOnly;
  const ProductsGrid(
    this._showFavoritesOnly, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        (_showFavoritesOnly) ? productsData.favItems : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, index) {
        return ChangeNotifierProvider.value(
          // create: (c) => products[index],
          value: products[index],
          child: ProductItem(),
        );
      },
      itemCount: products.length,
    );
  }
}
