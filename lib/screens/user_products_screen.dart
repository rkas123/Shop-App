import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

import './edit_product_screen.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/user-products-screen';
  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  bool _initialRenderDone = false;
  bool _showloader = false;
  Future<void> _refreshProducts(BuildContext context) async {
    return Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(filterByUser: true);
  }

  @override
  void didChangeDependencies() {
    if (!_initialRenderDone) {
      setState(() => _showloader = true);
      _refreshProducts(context).then((_) {
        _initialRenderDone = true;
        setState(() => _showloader = false);
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: (_showloader == true)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  itemBuilder: (ctx, index) => Column(
                    children: [
                      UserProductItem(
                        title: products.items[index].title,
                        url: products.items[index].imageUrl,
                        id: products.items[index].id,
                      ),
                      const Divider(),
                    ],
                  ),
                  itemCount: products.items.length,
                ),
              ),
            ),
    );
  }
}
