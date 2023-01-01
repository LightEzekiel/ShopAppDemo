import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../provider/cart.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<cartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String? authToken;
  String? userId;

  void update(String? token, String? authUser) {
    authToken = token;
    userId = authUser;
  }

  List<OrderItem> get orders {
    return [..._orders]; // returns a copy
  }

  Future<void> fetchAndSetOrders() async {
    // fetOrders without userId
    // final url =
    //     'https://flutter-update-23b95-default-rtdb.firebaseio.com/orders.json?auth=$authToken';

    final url =
        'https://flutter-update-23b95-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final List<OrderItem> loadedOrders = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        return;
      }
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
            id: orderId,
            amount: orderData['amount'],
            products: (orderData['product'] as List<dynamic>)
                .map((item) => cartItem(
                    id: item['id'],
                    title: item['title'],
                    price: item['price'],
                    quantity: item['quantity']))
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime'])));
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<cartItem> cartProducts, double total) async {
    //Implement error handling here later.
    final url =
        'https://flutter-update-23b95-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timeStamp = DateTime.now();
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          'dateTime': timeStamp.toIso8601String(),
          'amount': total,
          'product': cartProducts
              .map((cp) => {
                    'title': cp.title,
                    'id': cp.id,
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList()
        }));

    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timeStamp));
    notifyListeners();
  }
}
