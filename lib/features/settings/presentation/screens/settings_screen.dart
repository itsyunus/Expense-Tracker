import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../services/biometric_service.dart';
import '../../../../services/export_service.dart';
import '../widgets/theme_switch.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricEnabled = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final biometricService = BiometricService();
    final isAvailable = await biometricService.isAvailable();
    if (mounted) {
      setState(() => _isBiometricAvailable = isAvailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              title: Text(
                AppStrings.settings,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Appearance Section
            _buildSection(
              title: AppStrings.appearance,
              children: [
                _buildSettingTile(
                  icon: Icons.dark_mode_outlined,
                  title: AppStrings.darkMode,
                  trailing: const AnimatedThemeSwitch(),
                  isDarkMode: isDarkMode,
                ),
              ],
              isDarkMode: isDarkMode,
            ),

            // Security Section
            if (_isBiometricAvailable)
              _buildSection(
                title: AppStrings.security,
                children: [
                  _buildSettingTile(
                    icon: Icons.fingerprint,
                    title: AppStrings.biometricLock,
                    trailing: Switch(
                      value: _biometricEnabled,
                      onChanged: (value) async {
                        HapticFeedback.selectionClick();
                        if (value) {
                          final success = await BiometricService().authenticate(
                            reason: 'Authenticate to enable biometric lock',
                          );
                          if (success && mounted) {
                            setState(() => _biometricEnabled = true);
                          }
                        } else {
                          setState(() => _biometricEnabled = false);
                        }
                      },
                    ),
                    isDarkMode: isDarkMode,
                  ),
                ],
                isDarkMode: isDarkMode,
              ),

            // Export Section
            _buildSection(
              title: AppStrings.exportData,
              children: [
                _buildSettingTile(
                  icon: Icons.table_chart_outlined,
                  title: AppStrings.exportCSV,
                  onTap: () => _exportData('csv'),
                  trailing: const Icon(Icons.chevron_right),
                  isDarkMode: isDarkMode,
                ),
                _buildSettingTile(
                  icon: Icons.picture_as_pdf_outlined,
                  title: AppStrings.exportPDF,
                  onTap: () => _exportData('pdf'),
                  trailing: const Icon(Icons.chevron_right),
                  isDarkMode: isDarkMode,
                ),
              ],
              isDarkMode: isDarkMode,
            ),

            // About Section
            _buildSection(
              title: AppStrings.about,
              children: [
                _buildSettingTile(
                  icon: Icons.info_outline,
                  title: AppStrings.version,
                  trailing: Text(
                    '1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  isDarkMode: isDarkMode,
                ),
                _buildSettingTile(
                  icon: Icons.code,
                  title: 'Made with Flutter',
                  trailing: const Icon(Icons.favorite, color: Colors.red, size: 20),
                  isDarkMode: isDarkMode,
                ),
                _buildSettingTile(
                  icon: Icons.person_outline,
                  title: 'Made by',
                  trailing: Text(
                    'Shaik Mohammad Yunus',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  isDarkMode: isDarkMode,
                ),
              ],
              isDarkMode: isDarkMode,
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required bool isDarkMode,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title),
      trailing: trailing,
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
    );
  }

  Future<void> _exportData(String format) async {
    HapticFeedback.mediumImpact();
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final exportService = ExportService();
      String? filePath;

      if (format == 'csv') {
        filePath = await exportService.exportToCSV();
      } else {
        filePath = await exportService.exportToPDF();
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(filePath != null 
                ? AppStrings.exportSuccess 
                : 'No expenses to export'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: filePath != null
                ? SnackBarAction(
                    label: 'Share',
                    onPressed: () => exportService.shareFile(filePath!),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
