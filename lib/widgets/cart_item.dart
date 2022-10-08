import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final double price;
  final int quantity;
  final String title;
  final String keyid;
  const CartItem({
    required this.id,
    required this.price,
    required this.quantity,
    required this.title,
    required this.keyid,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Consumer<Cart>(
          builder: (ctx, cart, child) => Dismissible(
            key: ValueKey(id),
            direction: DismissDirection.endToStart,
            background: Container(
              padding: const EdgeInsets.only(right: 20),
              alignment: Alignment.centerRight,
              color: Theme.of(context).errorColor,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 40,
              ),
            ),
            onDismissed: (direction) {
              cart.removeItem(keyid);
            },
            confirmDismiss: (direction) {
              return showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Are you sure?'),
                  content:
                      const Text('Do you want to remove the item from cart?'),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                      child: const Text('No'),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                  child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: FittedBox(child: Text('\$$price')))),
              title: Text(title),
              subtitle: Text('Total: \$${(price * quantity)}'),
              trailing: Text('$quantity x'),
            ),
          ),
        ),
      ),
    );
  }
}
