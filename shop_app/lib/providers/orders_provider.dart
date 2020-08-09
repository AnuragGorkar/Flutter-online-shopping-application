
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './order_item.dart';
import './cart_item.dart';

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://myshopapp-0411.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProducts
                .map((cartProduct) => {
                      'id': cartProduct.productId,
                      'title': cartProduct.title,
                      'quantity': cartProduct.quantity,
                      'price': cartProduct.price,
                    })
                .toList()
          }));
      _orders.insert(
          0,
          OrderItem(
              id: json.decode(response.body)['name'],
              products: cartProducts,
              amount: total,
              dateTime: timeStamp));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndDisplayOrders() async {
    final url = 'https://myshopapp-0411.firebaseio.com/orders/$userId.json?auth=$authToken';
    final List<OrderItem> loadedOrders = [];
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData != null) {
        extractedData.forEach((orderId, orderData) {
          loadedOrders.add(
            OrderItem(
              id: orderId,
              amount: orderData['amount'],
              dateTime: DateTime.parse(orderData['dateTime']),
              products: (orderData['products'] as List<dynamic>)
                  .map(
                    (item) => CartItem(
                      id:item['id'],
                      productId: item['productId'],
                      price: item['price'],
                      title: item['title'],
                      quantity: item['quantity'],
                    ),
                  )
                  .toList(),
            ),
          );
        });
        _orders = loadedOrders;
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }
}
