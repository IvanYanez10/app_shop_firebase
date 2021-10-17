import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu carrito'),
      ),
      body: Column(children: <Widget>[
        Card(
          margin: const EdgeInsets.all(15),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
              const Text(
                'Total',
                style: TextStyle(fontSize: 20)
              ),
              Spacer(),
              Chip(
                label: Text('\$${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white)
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              OrderButton(cart: cart)
            ])
          )
        ),
        const SizedBox(height: 10),
        Expanded(child: ListView.builder(
          itemCount: cart.items.length,
          itemBuilder: (ctx, i) => CartItem(
              cart.items.values.toList()[i].id,
              cart.items.keys.toList()[i],
              cart.items.values.toList()[i].price,
              cart.items.values.toList()[i].quantity,
              cart.items.values.toList()[i].title
            ),
          ),
        ),
      ])
    );
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;

  OrderButton({required this.cart});

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final scaffold  = ScaffoldMessenger.of(context);
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 15),
      ),
      child: _isLoading ? CircularProgressIndicator() : const Text('COMPRAR AHORA'),
      onPressed: (widget.cart.totalAmount<=0 || _isLoading)
          ? null
          : () async {
            setState(() {
              _isLoading = true;
            });
            try{
              await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.items.values.toList(),
                  widget.cart.totalAmount);
              scaffold.hideCurrentSnackBar();
              scaffold.showSnackBar(const SnackBar(
                content: Text(
                  'Orden agregada',
                  textAlign: TextAlign.center,
                ),
                duration: Duration(seconds: 1),
              ));
            }catch(error){
              scaffold.hideCurrentSnackBar();
              scaffold.showSnackBar(const SnackBar(
                content: Text(
                  'Fallo al eliminar',
                  textAlign: TextAlign.center,
                ),
                duration: Duration(seconds: 1),
              ));
            }
            setState(() {
              _isLoading = false;
            });
            widget.cart.clear();
      },
    );
  }
}
