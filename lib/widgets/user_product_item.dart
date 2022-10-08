import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String url;
  final String id;
  const UserProductItem({
    required this.id,
    required this.title,
    required this.url,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(url),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  EditProductScreen.routeName,
                  arguments: id,
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deleteProduct(id);
                  scaffold.hideCurrentSnackBar();
                  scaffold.showSnackBar(SnackBar(
                    content: const Text('Item deleted Successfully'),
                    action: SnackBarAction(
                      label: 'Close',
                      onPressed: () {},
                    ),
                    duration: const Duration(seconds: 2),
                  ));
                } catch (error) {
                  scaffold.hideCurrentSnackBar();
                  scaffold.showSnackBar(SnackBar(
                    content: Text(
                        'Delete Item failed due to \'${error.toString()}\''),
                    action: SnackBarAction(
                      label: 'Close',
                      onPressed: () {},
                    ),
                    duration: const Duration(seconds: 2),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
