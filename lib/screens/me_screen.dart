import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'CC';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: StitchTheme.cardDecoration,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: StitchTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(provider.userName),
                        style: StitchTheme.headlineLg(context).copyWith(
                          fontSize: 18,
                          color: StitchTheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.userName,
                          style: StitchTheme.headlineLg(context).copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${provider.userRole} Professional',
                          style: StitchTheme.bodyMd(context),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.userEmail,
                          style: StitchTheme.monoSm(context),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: StitchTheme.primary),
                    tooltip: 'Edit Profile',
                    onPressed: () => _showEditProfileDialog(context, provider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cloud & Privacy
            Text('CLOUD & PRIVACY', style: StitchTheme.labelCaps(context)),
            const SizedBox(height: 8),
            Container(
              decoration: StitchTheme.cardDecoration,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Cloud Sync (Firestore)',
                      style: StitchTheme.headlineMd(context).copyWith(fontSize: 15),
                    ),
                    subtitle: Text(
                      provider.cloudSyncEnabled
                          ? 'Backing up gear, gigs & rentals to your private cloud'
                          : '100% offline mode active. No data leaves this device.',
                      style: StitchTheme.bodyMd(context),
                    ),
                    value: provider.cloudSyncEnabled,
                    activeThumbColor: StitchTheme.primary,
                    onChanged: (val) {
                      provider.toggleCloudSync(val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            val
                                ? 'Cloud Sync enabled'
                                : 'Cloud Sync disabled. Running 100% offline.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data Management
            Text('DATA & BACKUPS', style: StitchTheme.labelCaps(context)),
            const SizedBox(height: 8),
            Container(
              decoration: StitchTheme.cardDecoration,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download_outlined, color: StitchTheme.primary),
                    title: Text('Export Backup (JSON)', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                    subtitle: Text('Export full inventory, gigs, and rentals', style: StitchTheme.bodyMd(context)),
                    trailing: const Icon(Icons.chevron_right, color: StitchTheme.outline),
                    onTap: () => _showExportDialog(context, provider),
                  ),
                  const Divider(height: 1, color: StitchTheme.outlineVariant),
                  ListTile(
                    leading: const Icon(Icons.upload_outlined, color: StitchTheme.primary),
                    title: Text('Import Backup (JSON)', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                    subtitle: Text('Restore gear & gigs from backup file or text', style: StitchTheme.bodyMd(context)),
                    trailing: const Icon(Icons.chevron_right, color: StitchTheme.outline),
                    onTap: () => _showImportDialog(context, provider),
                  ),
                  const Divider(height: 1, color: StitchTheme.outlineVariant),
                  ListTile(
                    leading: const Icon(Icons.refresh_outlined, color: StitchTheme.error),
                    title: Text('Reset to Demo Data', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15, color: StitchTheme.error)),
                    subtitle: Text('Restores default sample gear and wedding gig', style: StitchTheme.bodyMd(context)),
                    onTap: () => _showResetConfirmation(context, provider),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About & Open Source
            Text('ABOUT & FOSS', style: StitchTheme.labelCaps(context)),
            const SizedBox(height: 8),
            Container(
              decoration: StitchTheme.cardDecoration,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: StitchTheme.primary),
                    title: Text('Version', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                    subtitle: const Text('1.0.0+1 (F-Droid Build)', style: TextStyle(fontFamily: 'monospace', fontSize: 13)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: StitchTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: StitchTheme.outlineVariant),
                      ),
                      child: Text('FOSS', style: StitchTheme.labelCaps(context).copyWith(color: StitchTheme.success)),
                    ),
                  ),
                  const Divider(height: 1, color: StitchTheme.outlineVariant),
                  ListTile(
                    leading: const Icon(Icons.verified_outlined, color: StitchTheme.primary),
                    title: Text('Open Source License', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                    subtitle: const Text('MIT License', style: TextStyle(fontSize: 13)),
                    trailing: const Icon(Icons.chevron_right, color: StitchTheme.outline),
                    onTap: () => _showLicenseDialog(context),
                  ),
                  const Divider(height: 1, color: StitchTheme.outlineVariant),
                  ListTile(
                    leading: const Icon(Icons.code_outlined, color: StitchTheme.primary),
                    title: Text('Package ID', style: StitchTheme.headlineMd(context).copyWith(fontSize: 15)),
                    subtitle: const Text('com.checkerchecks.checkerchecks', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppProvider provider) {
    final nameCtrl = TextEditingController(text: provider.userName);
    final emailCtrl = TextEditingController(text: provider.userEmail);
    String selectedRole = provider.userRole;

    const roles = [
      'Photography',
      'Video',
      'Audio',
      'Hybrid Creator',
      'Rental House',
      'Filmmaker',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StitchTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Profile', style: StitchTheme.headlineLg(ctx)),
                  const SizedBox(height: 16),
                  Text('FULL NAME', style: StitchTheme.labelCaps(ctx)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Your name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('EMAIL ADDRESS', style: StitchTheme.labelCaps(ctx)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'name@studio.com',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('ROLE / DISCIPLINE', style: StitchTheme.labelCaps(ctx)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: roles.contains(selectedRole) ? selectedRole : roles.first,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: roles
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (nameCtrl.text.trim().isNotEmpty) {
                            provider.updateProfile(
                              name: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              role: selectedRole,
                            );
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile updated successfully')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StitchTheme.primary,
                          foregroundColor: StitchTheme.onPrimary,
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showExportDialog(BuildContext context, AppProvider provider) {
    final jsonString = provider.exportDataAsJson();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Backup (JSON)'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Copy this JSON backup to safely archive your inventory, gigs, and rentals offline:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                height: 180,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StitchTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: StitchTheme.outlineVariant),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonString,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy to Clipboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchTheme.primary,
              foregroundColor: StitchTheme.onPrimary,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonString));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup JSON copied to clipboard!')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, AppProvider provider) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Backup (JSON)'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste your JSON backup data below to restore gear, gigs, and rentals:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Paste backup JSON here...',
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchTheme.primary,
              foregroundColor: StitchTheme.onPrimary,
            ),
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              final success = provider.importDataFromJson(text);
              Navigator.of(ctx).pop();
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup restored successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to parse backup JSON. Please check formatting.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Restore Data'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Demo Data?'),
        content: const Text(
          'This will replace your current inventory and gigs with default sample data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchTheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.resetToDefaults();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sample demo data restored.')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('MIT License'),
        content: const SingleChildScrollView(
          child: Text(
            'Copyright (c) 2026 CheckerChecks Contributors\n\n'
            'Permission is hereby granted, free of charge, to any person obtaining a copy '
            'of this software and associated documentation files (the "Software"), to deal '
            'in the Software without restriction, including without limitation the rights '
            'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
            'copies of the Software, and to permit persons to whom the Software is '
            'furnished to do so, subject to the following conditions:\n\n'
            'The above copyright notice and this permission notice shall be included in all '
            'copies or substantial portions of the Software.\n\n'
            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
            'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
            'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.',
            style: TextStyle(fontSize: 12, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
