import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/screen/orders_screen.dart';
import 'package:shop_app/screen/user_products_screen.dart';

class Appdrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text(
              "Hello Customer!",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false,
          ),
          Container(
            width: double.infinity,
            height: 5,
            color: Theme.of(context).accentColor,
          ), 
          ListTile(
            leading: Icon(
              Icons.shop,
              color: Theme.of(context).accentColor,
              size: 30,
            ),
            title: Text(
              "Shop",
              style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.payment,
              color: Theme.of(context).accentColor,
              size: 30,
            ),
            title: Text(
              "Orders",
              style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),
           Divider(),
          ListTile(
            leading: Icon(
              Icons.edit,
              color: Theme.of(context).accentColor,
              size: 30,
            ),
            title: Text(
              "Manage Products",
              style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).accentColor,
              size: 30,
            ),
            title: Text(
              "Logout",
              style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
