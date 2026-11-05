import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

enum _Version { a, b }

/// Level 4: a countdown, two ways.
class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  _Version _version = _Version.a;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<_Version>(
              segments: const [
                ButtonSegment(
                  value: _Version.a,
                  label: Text('A · StreamBuilder'),
                ),
                ButtonSegment(value: _Version.b, label: Text('B · listen')),
              ],
              selected: {_version},
              onSelectionChanged: (s) => setState(() => _version = s.first),
            ),
          ),
          Expanded(
            child: Center(
              child: switch (_version) {
                _Version.a => const _StreamBuilderCountdown(),
                _Version.b => const _ListenCountdown(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Version A: StreamBuilder subscribes and cancels for you.
class _StreamBuilderCountdown extends StatefulWidget {
  const _StreamBuilderCountdown();

  @override
  State<_StreamBuilderCountdown> createState() =>
      _StreamBuilderCountdownState();
}

class _StreamBuilderCountdownState extends State<_StreamBuilderCountdown> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) => Text(
        '${snapshot.data ?? 10}',
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}

/// Version B: you subscribe with listen, so you cancel in dispose.
class _ListenCountdown extends StatefulWidget {
  const _ListenCountdown();

  @override
  State<_ListenCountdown> createState() => _ListenCountdownState();
}

class _ListenCountdownState extends State<_ListenCountdown> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    _sub.cancel(); // without this: ticks for a dead screen + setState after dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_left', style: Theme.of(context).textTheme.displayLarge);
  }
}
