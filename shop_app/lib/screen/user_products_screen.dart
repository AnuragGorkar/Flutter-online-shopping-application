import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import '../screen/edit_product_screen.dart';
import '../providers/products_provider.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = 'user-products-screen';

  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndDisplayProudcts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Products"),
          actions: <Widget>[
            Builder(
              builder: (context) => IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final title = await Navigator.of(context).pushNamed(
                        EditProductScreen.routeName,
                        arguments: [null, true]);
                    if (title != null)
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text("$title is added to products"),
                          ),
                        );
                  }),
            )
          ],
        ),
        drawer: Appdrawer(),
        body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () => _refreshProducts(context),
                  child: Consumer<Products>(
                    builder: (context, productsData, _) => Padding(
                      padding: EdgeInsets.all(8),
                      child: productsData.items.length == 0
                          ? Center(
                              child: Text(
                                "You have not added any products yet !!!",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: productsData.items.length,
                              itemBuilder: (context, index) => Column(
                                    children: <Widget>[
                                      UserProductItem(
                                        id: productsData.items[index].id,
                                        title: productsData.items[index].title,
                                        imageUrl:
                                            productsData.items[index].imageUrl,
                                      ),
                                      Divider(
                                        indent: 10,
                                      ),
                                    ],
                                  )),
                    ),
                  ),
                ),
        ));
  }
}
