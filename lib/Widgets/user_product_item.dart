import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Screens/edit_product_screen.dart';
import '../provider/products.dart';

class UserProductItem extends StatelessWidget {
  String id;
  String title;
  String imageUrl;

  UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          imageUrl,
        ),
      ),
      trailing: Container(
        width: 100,
        child: Row(children: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreens.routeName, arguments: id);
              },
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor),
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: Text('Delete Product?'),
                          content: Text('$title will be deleted from list?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Text('NO')),
                            TextButton(
                                onPressed: () async {
                                  try {
                                    Provider.of<Products>(context,
                                            listen: false)
                                        .deleteProduct(id);
                                    Navigator.of(context).pop(true);
                                  } catch (error) {
                                    scaffold.showSnackBar(SnackBar(
                                        content: Text(
                                      'Delecting failed!',
                                      textAlign: TextAlign.center,
                                    )));

                                    // showSnackBar(SnackBar(
                                    //     content: Text('Delecting failed!',textAlign: TextAlign.center ,)));
                                  }
                                },
                                child: Text('YES')),
                          ],
                        ));
                // Provider.of<Products>(context, listen: false).deleteProduct(id);
              },
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor)
        ]),
      ),
    );
  }
}
