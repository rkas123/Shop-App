import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';

import '../widgets/order_item.dart' as oi_widget;
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;
  bool _notFetched = false;
  List<OrderItem> orderData = [];

  @override
  void initState() {
    final ordersListener = Provider.of<Orders>(context, listen: false);
    ordersListener.fetchAndSetOrders().then((_) {
      orderData = ordersListener.orders;
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _notFetched = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: (_notFetched)
          ? const Center(child: Text('Unable to fetch data!'))
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemBuilder: (ctx, index) => oi_widget.OrderItem(
                    order: orderData.orders[index],
                  ),
                  itemCount: orderData.orders.length,
                ),
    );
  }
}
