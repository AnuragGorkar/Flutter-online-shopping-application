import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';
import '../widgets/cart_item.dart' as cI;
import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  static const routeName = "/cart-screen";

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() async{
    if (_isInit)  {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Cart>(context).fetchAndDisplayCart().then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: <Widget>[
                Card(
                  margin: EdgeInsets.all(15),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Spacer(),
                        Chip(
                          label: Text(
                            "₹ ${cart.totalAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .headline6
                                  .color,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        OrderButton(cart: cart),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                      itemCount: cart.itemCount,
                      itemBuilder: (context, index) => cI.CartItem(
                            id: cart.items[index].id,
                            productId: cart.items[index].productId,
                            price: cart.items[index].price,
                            title: cart.items[index].title,
                            quantity: cart.items[index].quantity,
                          )),
                ),
              ],
            ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  var _orderPlaced = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading == true)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await Provider.of<Orders>(context, listen: false).addOrder(
                    widget.cart.items.toList(), widget.cart.totalAmount);
                setState(() {
                  _isLoading = false;
                });
                Scaffold.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text("Order placed"),
                    ),
                  );
                _orderPlaced = true;
              } catch (error) {
                setState(() {
                  _isLoading = false;
                });
                Scaffold.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text("Order could not be placed"),
                    ),
                  );
                _orderPlaced = false;
              }
              if (_orderPlaced) await Provider.of<Cart>(context, listen: false).clearCart();
            },
      child: _isLoading
          ? CircularProgressIndicator()
          : Text(
              "Order Now",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
    );
  }
}
