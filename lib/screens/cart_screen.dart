import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/orders.dart';

import '../widgets/cart_item.dart' as ci;

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final cartValues = cart.items.values.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (ctx, index) => ci.CartItem(
                id: cartValues[index].id,
                keyid: cart.items.keys.toList()[index],
                title: cartValues[index].title,
                quantity: cartValues[index].quantity,
                price: cartValues[index].price),
            itemCount: cart.itemcount,
          )),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: Padding(
            padding: EdgeInsets.all(3),
            child: CircularProgressIndicator(),
          ))
        : FlatButton(
            onPressed: widget.cart.totalAmount <= 0
                ? null
                : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      await Provider.of<Orders>(
                        context,
                        listen: false,
                      ).addOrder(
                        widget.cart.items.values.toList(),
                        widget.cart.totalAmount,
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      widget.cart.clear();
                      return showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Order placed successfully!'),
                          actions: [
                            FlatButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Close'),
                            )
                          ],
                        ),
                      );
                    } catch (error) {
                      setState(() {
                        _isLoading = false;
                      });
                      return showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Placing order failed!'),
                          content: Text('Error due to ${error.toString()}'),
                          actions: [
                            FlatButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Close'),
                            )
                          ],
                        ),
                      );
                    }
                  },
            child: Text(
              'ORDER NOW',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          );
  }
}
