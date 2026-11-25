import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Warm-up 1 (20 min): the counter, but the count lives in a ChangeNotifier
/// so two screens can show and change the same number.
///
/// Plan said out loud in the first two minutes:
///  1. Counter extends ChangeNotifier: value + increment/decrement.
///  2. ChangeNotifierProvider ABOVE MaterialApp — routes are siblings under
///     the Navigator, so a provider below MaterialApp would not reach screen 2.
///  3. watch in build (rebuild on change), read in onPressed (no subscription).
class Counter extends ChangeNotifier {
  int _value = 0;
  int get value => _value;

  void increment() {
    _value++;
    notifyListeners();
  }

  void decrement() {
    _value--;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Counter(),
      child: const CounterApp(),
    ),
  );
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warm-up 1',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CountText(),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SecondScreen()),
              ),
              child: const Text('Open second screen'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('increment'),
        // read: an event handler needs the object, not a subscription.
        onPressed: () => context.read<Counter>().increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second screen')),
      body: const Center(child: CountText()),
      floatingActionButton: FloatingActionButton(
        key: const Key('decrement'),
        onPressed: () => context.read<Counter>().decrement(),
        tooltip: 'Decrement',
        child: const Icon(Icons.remove),
      ),
    );
  }
}

/// The only widget that watches — so only this Text rebuilds on a change.
class CountText extends StatelessWidget {
  const CountText({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.watch<Counter>().value;
    return Text(
      'Count: $value',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
