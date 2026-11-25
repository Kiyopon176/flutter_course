import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/dev_host.dart';
import '../../core/env.dart';
import '../about/about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _photoPath;

  Future<void> _takePhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final shot = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
      );
      if (shot == null || !mounted) return; // user backed out
      setState(() => _photoPath = shot.path);
    } on PlatformException catch (e) {
      // camera_access_denied on Android/iOS when the user said no.
      final denied = e.code.contains('denied');
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            denied
                ? 'Camera permission denied — allow it in system settings.'
                : 'Camera unavailable: ${e.message ?? e.code}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: _photoPath == null
                  ? null
                  : FileImage(File(_photoPath!)),
              child: _photoPath == null ? const Icon(Icons.person) : null,
            ),
            title: const Text('Profile photo'),
            subtitle: const Text('Take photo'),
            trailing: const Icon(Icons.photo_camera_outlined),
            onTap: _takePhoto,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
          // Testers only. kDebugMode is a const, so in a release build this
          // tile — and the code behind it — is compiled out entirely.
          if (kDebugMode) const _DevHostTile(),
        ],
      ),
    );
  }
}

class _DevHostTile extends StatelessWidget {
  const _DevHostTile();

  @override
  Widget build(BuildContext context) {
    final dev = context.watch<DevHostSetting>();
    return ListTile(
      leading: const Icon(Icons.developer_mode),
      title: const Text('Developer: API host'),
      subtitle: Text(
        dev.override == null ? '${Env.host} (from build)' : dev.host,
      ),
      onTap: () => _edit(context, dev),
    );
  }

  Future<void> _edit(BuildContext context, DevHostSetting dev) async {
    final controller = TextEditingController(text: dev.host);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('API host (debug only)'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'jsonplaceholder.typicode.com or http://10.0.2.2:8080',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, ''),
            child: const Text('Reset'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Use'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null) await dev.setOverride(result);
  }
}
