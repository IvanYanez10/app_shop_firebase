import 'package:flutter/foundation.dart';
import './cart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authtoken;
  final String userId;

  Orders(this.authtoken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-store-fe173-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authtoken');
    final List<OrderItem> loadedOrders = [];
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((ordId, ordData) {
        loadedOrders.add(OrderItem(
            id: ordId,
            amount: ordData['amount'],
            products: (ordData['products'] as List<dynamic>)
                .map((item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    title: item['title'],
                    quantity: item['quantity']))
                .toList(),
            dateTime: DateTime.parse(ordData['dateTime'])));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-store-fe173-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authtoken');
    final timestamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price
                    })
                .toList(),
            'dateTime': timestamp.toIso8601String()
          }));
      _orders.insert(
          0,
          OrderItem(
              id: json.decode(response.body)['name'],
              amount: total,
              products: cartProducts,
              dateTime: timestamp));
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }
}
