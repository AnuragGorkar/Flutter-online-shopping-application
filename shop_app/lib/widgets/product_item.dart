import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product.dart';
import '../screen/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<Product>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailsScreen.routeName,
                arguments: _product.id);
          },
          child: Hero(
            tag: _product.id,
                      child: FadeInImage(
              placeholder: AssetImage('assets/images/original (1).png'),
              image: NetworkImage(
                _product.imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.50),
          leading: Consumer<Product>(
            builder: (context, product, child) => IconButton(
              icon: Icon(
                _product.isFavourite ? Icons.favorite : Icons.favorite_border,
                size: 25,
              ),
              color: Theme.of(context).accentColor.withOpacity(0.87),
              onPressed: () async {
                try {
                  await _product.toggleFavouriteStatus(
                    authData.token,
                    authData.userId,
                  );
                  Scaffold.of(context).hideCurrentSnackBar();
                  _product.isFavourite
                      ? Scaffold.of(context).showSnackBar(SnackBar(
                          content:
                              Text("${_product.title} added to favourites."),
                          duration: Duration(seconds: 2),
                          action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                _product.toggleFavouriteStatus(
                                    authData.token, authData.userId);
                              }),
                        ))
                      : Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "${_product.title} removed from favourites."),
                            duration: Duration(seconds: 2),
                            action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () {
                                  _product.toggleFavouriteStatus(
                                      authData.token, authData.userId);
                                }),
                          ),
                        );
                } catch (error) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Could not change favourite status for ${_product.title}."),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ),
          title: Text(
            _product.title,
            // style: TextStyle(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
              size: 25,
            ),
            color: Theme.of(context).accentColor.withOpacity(0.87),
            onPressed: () async {
              try {
                await Provider.of<Cart>(context, listen: false).addItem(
                  productId: _product.id,
                  price: _product.price,
                  title: _product.title,
                );
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${_product.title} added to cart."),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () async {
                          try {
                            await Provider.of<Cart>(context, listen: false)
                                .removeSingleItem(_product.id);
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "${_product.title} removed from the cart."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } catch (error) {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "${_product.title} could not beremoved from the cart."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }),
                  ),
                );
              } catch (error) {
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${_product.title} could not be to cart."),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
