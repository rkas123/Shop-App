import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_details_screen.dart';

import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = Scaffold.of(context);
    final loadedProduct = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              icon: Icon(
                loadedProduct.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () async {
                try {
                  await loadedProduct.toggleFavoriteStatus();
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(const SnackBar(
                    content: Text('Favorite Status Changed'),
                    duration: Duration(seconds: 1),
                  ));
                } catch (error) {
                  scaffoldMessenger.hideCurrentSnackBar();
                  scaffoldMessenger.showSnackBar(SnackBar(
                    content: Text(
                        'Favorite change failed due to ${error.toString()}'),
                    duration: const Duration(seconds: 1),
                  ));
                }
              },
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(
                  loadedProduct.id, loadedProduct.price, loadedProduct.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                  'Added Item to Cart',
                ),
                action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () => cart.removeItem(loadedProduct.id)),
                duration: const Duration(seconds: 2),
              ));
            },
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).accentColor,
            ),
          ),
          backgroundColor: Colors.black87,
          title: Text(
            loadedProduct.title,
            textAlign: TextAlign.center,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: loadedProduct.id,
            );
          },
          child: Image.network(
            loadedProduct.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
