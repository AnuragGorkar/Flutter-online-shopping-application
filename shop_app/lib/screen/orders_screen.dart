import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';
import '../providers/orders_provider.dart' show Orders;

class OrdersScreen extends StatefulWidget {
  static const routeName = "orders-screen";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = false;
  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Future.delayed(Duration.zero).then((_) async {
        try {
          setState(() {
            _isLoading = true;
          });
          await Provider.of<Orders>(context, listen: false)
              .fetchAndDisplayOrders();
          setState(() {
            _isLoading = false;
          });
        } catch (error) {
          setState(() {
            _isLoading = false;
          });
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text("An Error occured. Orders could not be loaded"),
              ),
            );
        }
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);

    bool _noOrdersPlaced = (orderData.orders.length == 0);

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      drawer: Appdrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _noOrdersPlaced
              ? Center(
                  child: Text(
                    "No Orders placed yet",
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (context, index) => OrderItem(
                    orderData.orders[index],
                  ),
                ),
    );
  }
}
