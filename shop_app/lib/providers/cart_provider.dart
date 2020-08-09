import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

import './cart_item.dart';

class Cart with ChangeNotifier {
  List<CartItem> _items = [];
  final String authToken;
  final String userId;
  int _itemCount = 0;

  Cart(this.authToken, this.userId, this._items);

  List<CartItem> get items {
    return [..._items];
  }

  int get itemCount {
    return _itemCount;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> fetchAndDisplayCart() async {
    final url =
        'https://myshopapp-0411.firebaseio.com/carts/$userId.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final List<CartItem> loadedCartItems = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData != null) {
        _itemCount = extractedData.length;
        extractedData.forEach((productId, productData) {
          loadedCartItems.add(
            CartItem(
              id: productId,
              productId: productData["productId"],
              price: productData["price"],
              quantity: productData["quantity"],
              title: productData["title"],
            ),
          );
        });
      }
      _items = loadedCartItems;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<String> get numberOfCartItems async {
    final url =
        'https://myshopapp-0411.firebaseio.com/carts/$userId.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      return extractedData.length.toString();
    } catch (error) {
      return 0.toString();
    }
  }

  bool ifItemAlreadyExists(String productId) {
    return _items
        .map((cartItem) => (cartItem.productId == productId).toString())
        .toList()
        .contains('true');
  }

  Future<void> addItem({String productId, double price, String title}) async {
    try {
      if (ifItemAlreadyExists(productId)) {
        var newCart = _items.firstWhere((cartItem) {
          return cartItem.title == title;
        });
        final String id = newCart.id;

        final url =
            'https://myshopapp-0411.firebaseio.com/carts/$userId/$id.json?auth=$authToken';
        final response = await http.patch(url,
            body: json.encode({
              "productId": newCart.productId,
              "title": newCart.title,
              "quantity": newCart.quantity + 1,
              "price": newCart.price,
            }));
        _items[_items.indexWhere((cartItem) => cartItem.title == title)]
            .quantity++;

        notifyListeners();
      } else {
        final url =
            'https://myshopapp-0411.firebaseio.com/carts/$userId.json?auth=$authToken';
        final response = await http.post(
          url,
          body: json.encode(
            {
              "productId": productId,
              "title": title,
              "quantity": 1,
              "price": price,
            },
          ),
        );
        final newCartItem = CartItem(
          title: title,
          quantity: 1,
          productId: productId,
          price: price,
          id: json.decode(response.body)["name"],
        );

        _items.add(newCartItem);
        _itemCount++;
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> removeItem(String id, String productId) async {
    final url =
        'https://myshopapp-0411.firebaseio.com/carts/$userId/$id.json?auth=$authToken';
    final _existingCartItemIndex =
        _items.indexWhere((cartItem) => cartItem.productId == productId);
    var _existingCartItem = _items[_existingCartItemIndex];
    _items.removeAt(_existingCartItemIndex);
    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete Product');
      }
    } catch (error) {
      _items.insert(_existingCartItemIndex, _existingCartItem);
      notifyListeners();
      throw error;
    }
    _existingCartItem = null;
    _itemCount--;
    notifyListeners();
  }

  Future<void> clearCart() async {
    final url =
        'https://myshopapp-0411.firebaseio.com/carts/$userId.json?auth=$authToken';
    var existingItems = _items;
    try {
      _items = [];
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete Product');
      }
      existingItems = null;
    } catch (error) {
      _items = existingItems;
      notifyListeners();
      throw error;
    }
    _itemCount = 0;
    notifyListeners();
  }

  Future<void> removeSingleItem(String productId) async {
    if (ifItemAlreadyExists(productId)) {
      var existiongCart = _items.firstWhere((cartItem) {
        return cartItem.productId == productId;
      });
      final String id = existiongCart.id;

      final url =
          'https://myshopapp-0411.firebaseio.com/carts/$userId/$id.json?auth=$authToken';
      try {
        if (existiongCart.quantity > 1) {
          final response = await http.patch(
            url,
            body: json.encode(
              {
                "productId": existiongCart.productId,
                "title": existiongCart.title,
                "quantity": existiongCart.quantity - 1,
                "price": existiongCart.price,
              },
            ),
          );

          if (response.statusCode >= 400) {
            throw HttpException('Could not remove Product');
          }
          _items[_items
                  .indexWhere((cartItem) => cartItem.productId == productId)]
              .quantity--;
        } else if (existiongCart.quantity == 1) {
          final response = await http.delete(url);

          if (response.statusCode >= 400) {
            throw HttpException('Could not remove Product');
          }
          _items.removeWhere((cartItem) => cartItem.productId == productId);
        }
      } catch (error) {
        throw error;
      }
      notifyListeners();
    }
  }
}
