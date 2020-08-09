import 'dart:math';
import 'package:flutter/material.dart';
import "package:intl/intl.dart";

import '../providers/order_item.dart' as oI;

class OrderItem extends StatefulWidget {
  final oI.OrderItem order;

  OrderItem(@required this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 320),
      height: _expanded ? min(widget.order.products.length * 20.0 + 130 , 220.0) : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Row(
                children: <Widget>[
                  Text(
                    "Order Total:",
                    style: TextStyle(
                        fontSize: 17,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      "₹ ${widget.order.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.headline6.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              subtitle: Text(
                DateFormat('dd/MM/yyyy/hh/mm').format(widget.order.dateTime),
              ),
              trailing: IconButton(
                  icon: _expanded
                      ? Icon(Icons.expand_less)
                      : Icon(Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  }),
            ),
         
              AnimatedContainer(
                duration: Duration(milliseconds: 320),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                height: _expanded ? min(widget.order.products.length * 20.0 + 30, 120) : 0,
                child: ListView(
                  children: widget.order.products
                      .map((product) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                product.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  "${product.quantity}x     ₹ ${product.price}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ],
                          ))
                      .toList(),
                ),
              )
          ],
        ),
      ),
    );
  }
}
