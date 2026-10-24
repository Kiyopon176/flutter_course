import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;
  int _passwordLength = 0;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? v) =>
      (v ?? '').trim().length < 2 ? 'Name is too short' : null;

  String? _validateEmail(String? v) {
    final text = (v ?? '').trim();
    final at = text.indexOf('@');
    if (at < 0 || text.indexOf('.', at) < 0) return 'Email looks wrong';
    return null;
  }

  String? _validatePassword(String? v) =>
      (v ?? '').length < 8 ? 'Password is too short' : null;

  String? _validateConfirm(String? v) =>
      v == _password.text ? null : 'Passwords do not match';

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      setState(() => _done = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account created')));
    }
  }

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (mounted) {
      _birthText.text =
          '${picked.day.toString().padLeft(2, '0')}.'
          '${picked.month.toString().padLeft(2, '0')}.${picked.year}';
      setState(() => _birth = picked);
    }
  }

  void _startOver() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.clear();
    }
    setState(() {
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
      _passwordLength = 0;
    });
  }

  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _done ? _buildSummary() : _buildForm(),
    ),
  );

  Widget _buildSummary() => Column(
    children: [
      SummaryCard(
        name: _name.text.trim(),
        email: _email.text.trim(),
        group: _group ?? '',
        birth: _birthText.text,
      ),
      TextButton(onPressed: _startOver, child: const Text('Start over')),
    ],
  );

  Widget _buildForm() => Form(
    key: _formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _name,
          validator: _validateName,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
          onTapOutside: (_) => _dismissKeyboard(),
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _email,
          focusNode: _emailFocus,
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onTapOutside: (_) => _dismissKeyboard(),
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'name@kbtu.kz',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _password,
          validator: _validatePassword,
          obscureText: true,
          textInputAction: TextInputAction.next,
          onChanged: (v) => setState(() => _passwordLength = v.length),
          onTapOutside: (_) => _dismissKeyboard(),
          decoration: const InputDecoration(
            labelText: 'Password',
            helperText: 'At least 8 characters',
          ),
        ),
        Text('$_passwordLength of 8'),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirm,
          validator: _validateConfirm,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _agreed ? _signUp() : null,
          onTapOutside: (_) => _dismissKeyboard(),
          decoration: const InputDecoration(labelText: 'Confirm password'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _group,
          validator: (g) => g == null ? 'Choose a group' : null,
          decoration: const InputDecoration(labelText: 'Group'),
          items: [
            for (final g in groups) DropdownMenuItem(value: g, child: Text(g)),
          ],
          onChanged: (g) => setState(() => _group = g),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _birthText,
          readOnly: true,
          validator: (_) => _birth != null ? null : 'Pick a date of birth',
          onTap: _pickBirth,
          decoration: const InputDecoration(
            labelText: 'Date of birth',
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('I agree to the rules'),
          value: _agreed,
          onChanged: (v) => setState(() => _agreed = v ?? false),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _agreed ? _signUp : null,
          child: const Text('Sign up'),
        ),
      ],
    ),
  );
}
