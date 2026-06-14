import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/themes/app_sizes.dart';

/// About screen (Figma 22 — "О приложении").
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String packageName = '';
  String version = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final info = await PackageInfo.fromPlatform();
      packageName = info.packageName;
      version = info.version;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final muted = textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);
    final body = textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.45);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr('about_title'), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jesr POS', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.padding / 4),
            Text(packageName, style: muted),
            Text('version $version', style: muted),
            const SizedBox(height: AppSizes.padding),
            Text(
              context.tr('about_description_1'),
              style: body,
            ),
            const SizedBox(height: AppSizes.padding),
            Text(
              context.tr('about_description_2'),
              style: body,
            ),
            const SizedBox(height: AppSizes.padding),
            Text(
              context.tr('about_description_3'),
              style: body,
            ),
          ],
        ),
      ),
    );
  }
}
