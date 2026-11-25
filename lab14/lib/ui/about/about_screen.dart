import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../core/dev_host.dart';
import '../../core/env.dart';

const buildMode = kReleaseMode
    ? 'release'
    : kProfileMode
    ? 'profile'
    : 'debug';

/// Tells you which build you are holding: version, mode, environment, host.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devOverride = context.select<DevHostSetting?, String?>(
      (d) => d?.override,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snap) {
          final info = snap.data;
          if (info == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final version = '${info.version} (${info.buildNumber})';
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  '$version · $buildMode · ${Env.name} · ${Env.host}',
                  key: const Key('about-summary'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(),
              ListTile(title: const Text('Version'), subtitle: Text(version)),
              ListTile(
                title: const Text('Package'),
                subtitle: Text(info.packageName),
              ),
              const ListTile(
                title: Text('Build mode'),
                subtitle: Text(buildMode),
              ),
              const ListTile(
                title: Text('Environment'),
                subtitle: Text(Env.name),
              ),
              const ListTile(title: Text('API host'), subtitle: Text(Env.host)),
              if (Env.useFakes)
                const ListTile(
                  title: Text('Data source'),
                  subtitle: Text('USE_FAKES — no network'),
                ),
              if (devOverride != null)
                ListTile(
                  title: const Text('Developer host override'),
                  subtitle: Text(devOverride),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Open-source licences'),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Users',
                  applicationVersion: version,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
