import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('badge build');
    // select: rebuild only when the count changes, not on every notify
    // (a quantity change on the Cart screen does not touch this number).
    final n = context.select<Cart, int>((c) => c.count);
    return IconButton(
      onPressed: () => Navigator.of(context).pushNamed('/cart'),
      icon: Badge(label: Text('$n'), child: const Icon(Icons.shopping_cart)),
    );
  }
}
