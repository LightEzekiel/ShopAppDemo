import 'dart:convert';
import 'package:flutter/Material.dart';
import '../models/http_exception.dart';
import './product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  String? authToken;
  String? _userId;

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showfavoriteOnly = false;

  List<Product> get item {
    // if (_showfavoriteOnly) {
    //   return _items.where((element) => element.isFavourite).toList();
    // }
    return [..._items];
  }

  // void showFavoriteOnly() {
  //   _showfavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showfavoriteOnly = false;
  //   notifyListeners();
  // }

  void update(String? token, String? userId) {
    authToken = token;
    _userId = userId;
  }

  List<Product> get filterFavoriteItem {
    return _items.where((element) => element.isFavourite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    // fetch data by id
    // var url =
    //     'https://flutter-update-23b95-default-rtdb.firebaseio.com/products.json?auth=$authToken&orderBy="creatorId"&equalTo="$_userId"';

    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
    var url =
        'https://flutter-update-23b95-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';

    try {
      final response = await http.get(Uri.parse(url));
      // print(json.decode(response.body));
      final List<Product> loadedProducts = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        return;
      }

      url =
          'https://flutter-update-23b95-default-rtdb.firebaseio.com/userFavorites/$_userId.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(url));
      final favoriteData = json.decode(favoriteResponse.body);

      extractedData.forEach((prodId, productData) {
        loadedProducts.add(Product(
            id: prodId,
            title: productData['title'],
            description: productData['description'],
            imageUrl: productData['imageUrl'],
            price: productData['price'],
            isFavourite:
                favoriteData == null ? false : favoriteData[prodId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    //
    final url =
        'https://flutter-update-23b95-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    // return http
    //     .post(Uri.parse(url),
    //         body: json.encode({
    //           'title': product.title,
    //           'description': product.description,
    //           'imageUrl': product.imageUrl,
    //           'isFavorite': product.isFavourite
    //         }))
    //     .then((response) {
    //   final newProduct = Product(
    //       id: json.decode(response.body)['name'],
    //       title: product.title,
    //       description: product.description,
    //       imageUrl: product.imageUrl,
    //       price: product.price);
    //   _items.add(newProduct);
    //   notifyListeners();
    // }).catchError((error) {
    //   throw error;
    // });

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': _userId
          }));

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);

    if (productIndex >= 0) {
      final url =
          'https://flutter-update-23b95-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-update-23b95-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.\n Try again later.');
    }
    // ignore: null_check_always_fails
    existingProduct = null!;

    // _items.removeWhere((prod) => prod.id == id);
  }
}
