import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../provider/product.dart';
import 'package:provider/provider.dart';

import '../provider/products.dart';

class EditProductScreens extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  State<EditProductScreens> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreens> {
  // final _priceFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '', price: 0, title: '', description: '', imageUrl: '');

  var _isInit = true;

  var _initValues = {
    'price': '',
    'title': '',
    'description': '',
    'imageUrl': ''
  };

  var isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_UpdateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productid = ModalRoute.of(context)!.settings.arguments as String?;
      if (productid != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productid);
        _initValues = {
          'price': _editedProduct.price.toString(),
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          // 'imageUrl': _editedProduct.imageUrl
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _UpdateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (((_imageUrlController.text.startsWith('http') &&
              _imageUrlController.text.startsWith('https'))) &&
          ((_imageUrlController.text.endsWith('.png') &&
              _imageUrlController.text.endsWith('.jpg') &&
              _imageUrlController.text.endsWith('jpeg')))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      isLoading = true;
    });

    if (_editedProduct.id.isNotEmpty) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                content: Text('Something went wrong.'),
                title: Text('An error occured!.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text('Okay'))
                ],
              );
            });
      }
      // finally {
      //   setState(() {
      //     isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      isLoading = false;
    });

    Navigator.of(context).pop();

    // print(_editedProduct.title);
    // print(_editedProduct.id);
    // print(_editedProduct.description);
    // print(_editedProduct.price);
    // print(_editedProduct.imageUrl);
  }

  @override
  void dispose() {
    // _priceFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_UpdateImageUrl);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
              onPressed: () {
                _saveForm();
              },
              icon: Icon(Icons.save))
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        // onFieldSubmitted: (_) =>
                        onSaved: ((value) {
                          _editedProduct = Product(
                              isFavourite: _editedProduct.isFavourite,
                              id: _editedProduct.id,
                              title: value!,
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl);
                        }),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Title is required';
                          }
                        },
                        //     FocusScope.of(context).requestFocus(_priceFocusNode)
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        validator: ((value) {
                          if (value!.isEmpty) {
                            return 'Price is needed';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Enter a number greater than Zero';
                          }
                        }),
                        // focusNode: _priceFocusNode,
                        onSaved: ((value) {
                          _editedProduct = Product(
                              isFavourite: _editedProduct.isFavourite,
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: double.parse(value!),
                              imageUrl: _editedProduct.imageUrl);
                        }),
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Description is required';
                          }
                          if (value.length < 10) {
                            return 'Should be at least 10 char long';
                          }
                        },
                        // onFieldSubmitted: (_) =>
                        //     FocusScope.of(context).requestFocus(_priceFocusNode)
                        onSaved: ((value) {
                          _editedProduct = Product(
                              isFavourite: _editedProduct.isFavourite,
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: value!,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl);
                        }),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(right: 10, top: 8),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? Text(
                                    'Enter image Url',
                                    textAlign: TextAlign.center,
                                  )
                                : FittedBox(
                                    child: Image(
                                      image: CachedNetworkImageProvider(
                                        _imageUrlController.text,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter an image URL';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Enter a valid URL';
                                }
                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    value.endsWith('jpeg')) {
                                  return 'Enter a valid Image URL';
                                }
                              },
                              onSaved: ((value) {
                                _editedProduct = Product(
                                    isFavourite: _editedProduct.isFavourite,
                                    id: _editedProduct.id,
                                    title: _editedProduct.title,
                                    description: _editedProduct.description,
                                    price: _editedProduct.price,
                                    imageUrl: value!);
                              }),
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
