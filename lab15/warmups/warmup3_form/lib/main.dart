import 'package:flutter/material.dart';

import 'validators.dart';

/// Warm-up 3 (20 min): a form with two fields.
/// Controllers created once in State and disposed; Form + `GlobalKey<FormState>`;
/// the rules live in validators.dart and are unit-tested as plain functions.
void main() => runApp(const FormApp());

class FormApp extends StatelessWidget {
  const FormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warm-up 3',
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange),
      home: const SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Fields of State, not locals of build: build runs many times,
  // a controller created there would lose the text and leak.
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  String? _submitted;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitted = '${_name.text.trim()} <${_email.text.trim()}>');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              validator: validateName,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              onFieldSubmitted: (_) => _submit(),
              validator: validateEmail,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _submit, child: const Text('Submit')),
            if (_submitted != null) ...[
              const SizedBox(height: 16),
              Text('Submitted: $_submitted'),
            ],
          ],
        ),
      ),
    );
  }
}
