import 'package:flutter/material.dart';

import 'books_screen.dart';
import 'cart_screen.dart';

void main() => runApp(const Shell());

class Book {
  const Book({required this.title, required this.author, required this.price});

  final String title;
  final String author;
  final int price; // tenge
}

const books = [
  Book(
    title: 'Widgets All the Way Down',
    author: 'A. Nurmagambetova',
    price: 4200,
  ),
  Book(title: 'Null Safety for Humans', author: 'B. Seitkali', price: 3100),
  Book(
    title: 'Constraints Go Down, Sizes Go Up',
    author: 'C. Tashimova',
    price: 5600,
  ),
  Book(title: 'The Navigator Is a Stack', author: 'D. Alibekov', price: 2900),
  Book(
    title: 'Forms That Validate Themselves',
    author: 'E. Omarova',
    price: 3800,
  ),
  Book(
    title: 'Put It High, Subscribe Low',
    author: 'F. Kairatuly',
    price: 4700,
  ),
];

// Level 1: the owner of the cart. It sits ABOVE MaterialApp
// so that both routes can see the same list.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final List<Book> _cart = [];

  void _add(Book b) => setState(() => _cart.add(b));
  void _remove(Book b) => setState(() => _cart.remove(b));

  int get _total => _cart.fold(0, (sum, b) => sum + b.price);

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
    ),
    routes: {
      '/': (_) => BooksScreen(cart: _cart, total: _total, onAdd: _add),
      '/cart': (_) => CartScreen(items: _cart, onRemove: _remove),
    },
  );
}
