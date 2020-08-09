import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  bool _showFavoutitesOnly = false;
  List<Product> _items = [];
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  void setShowFavouritesOnly() {
    _showFavoutitesOnly = true;
    notifyListeners();
  }

  void setShowAll() {
    _showFavoutitesOnly = false;
    notifyListeners();
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favitems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndDisplayProudcts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://myshopapp-0411.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final List<Product> loadedProducts = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData != null) {
        url =
            'https://myshopapp-0411.firebaseio.com/userFavourites/$userId.json?auth=$authToken';
        final favouriteResponse = await http.get(url);
        final favouriteData = json.decode(favouriteResponse.body);
        extractedData.forEach((prodId, prodData) {
          loadedProducts.add(Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavourite: favouriteData == null
                  ? false
                  : favouriteData[prodId] ?? false));
        });
      }
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://myshopapp-0411.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((product) => product.id == id);
    try {
      if (prodIndex >= 0) {
        final url =
            'https://myshopapp-0411.firebaseio.com/products/$id.json?auth=$authToken';
        http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            }));
        _items[prodIndex] = newProduct;
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteProducts(String id) async {
    final url =
        'https://myshopapp-0411.firebaseio.com/products/$id.json?auth=$authToken';
    final _existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var _existingProduct = _items[_existingProductIndex];
    _items.removeAt(_existingProductIndex);
    notifyListeners();
    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _items.insert(_existingProductIndex, _existingProduct);
        notifyListeners();
        throw HttpException('Could not delete Product');
      }
    } catch (error) {
      _items.insert(_existingProductIndex, _existingProduct);
      notifyListeners();
    }
    _existingProduct = null;
  }
}
