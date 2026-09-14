import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppUpdateService {
  /// Checks for Play Store updates on app startup (Immediate or Flexible update)
  static Future<void> checkForUpdate() async {
    // In-App Updates are only supported on Android
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Perform Immediate Update for critical updates
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Perform Flexible Update for non-critical updates
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        }
      }
    } catch (e) {
      debugPrint('InAppUpdate check notice: $e');
    }
  }

  /// Manual check for updates (e.g. from Profile or About screen)
  static Future<void> manualCheckForUpdate(BuildContext context) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('In-App Updates are supported on Android Play Store.')),
        );
      }
      return;
    }

    try {
      // Show checking indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checking Google Play Store for updates...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        } else {
          if (context.mounted) {
            _openPlayStoreListing(context);
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your AnnaDaan app is up to date!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Manual InAppUpdate notice: $e');
      if (context.mounted) {
        _openPlayStoreListing(context);
      }
    }
  }

  /// Opens the Play Store app listing page directly as fallback
  static Future<void> _openPlayStoreListing(BuildContext context) async {
    const String packageName = 'com.vgsolutions.annadanam';
    final Uri playStoreUri = Uri.parse('market://details?id=$packageName');
    final Uri webUri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

    try {
      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Play Store page.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening Play Store: $e')),
        );
      }
    }
  }
}
