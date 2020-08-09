import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';

import '../screen/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String id;
  final String imageUrl;

  UserProductItem(
      {@required this.title, @required this.imageUrl, @required this.id});

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);

    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 96,
        child: Row(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  final itemEdited = await Navigator.of(context).pushNamed(
                      EditProductScreen.routeName,
                      arguments: [id, false]);
                  if (itemEdited != null)
                    scaffold.showSnackBar(
                        SnackBar(content: Text("Item edited successfully")));
                },
                color: Theme.of(context).primaryColor),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Are you sure?"),
                      content: Text(
                          "Do you want to delete $title from products list ?"),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                        FlatButton(
                          onPressed: () async {
                            try {
                               Navigator.of(context).pop(true);
                              await Provider.of<Products>(context,
                                      listen: false)
                                  .deleteProducts(id);
                              scaffold.showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "$title deleted from Products list."),
                                ),
                              );
                            } catch (error) {
                              scaffold.showSnackBar(SnackBar(
                                  content: Text("Item deletion Failed")));
                            }
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                color: Theme.of(context).errorColor),
          ],
        ),
      ),
    );
  }
}
