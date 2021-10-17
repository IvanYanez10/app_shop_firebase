import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                  arguments: product.id);
            },
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder: const AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover
              ),
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: Consumer<Product>(
                builder: (ctx, product, _) => IconButton(
                    icon: Icon(product.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border),
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      product.toggleFavoriteStatus(
                          authData.token, authData.userId);
                    })),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.shopping_cart),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Añadido al carrito'),
                  duration: const Duration(seconds: 1),
                  action: SnackBarAction(
                    label: 'Deshacer',
                    onPressed: () {
                      cart.removeItem(product.id);
                    },
                  ),
                ));
              },
            ),
          )),
    );
  }
}
