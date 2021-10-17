import 'package:course_shop/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ordenes')),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {
          if(dataSnapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }else if(dataSnapshot.error != null){
            return const Center(child: Text('Ocurrio un error'));
          }else{
            return Consumer<Orders>(
              builder: (ctx, orderData, child) =>
                ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx,i) => OrderItem(orderData.orders[i]))
            );
          }
        }
      )
    );
  }
}
