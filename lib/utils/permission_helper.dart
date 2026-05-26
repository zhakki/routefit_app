import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestBackgroundLocationPermission(
    BuildContext context,
  ) async {
    // Check current background location permission status
    var status = await Permission.locationAlways.status;

    if (status.isGranted) {
      return true;
    }

    // If not granted, show a dialog explaining why we need it
    if (!context.mounted) return false;

    bool? proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Background Tracking"),
        content: const Text(
          "To track your route while the screen is locked, you must set location permission to 'Allow all the time' in the next screen.\n\n"
          "This is required for accurate tracking even when the app is not visible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("OPEN SETTINGS"),
          ),
        ],
      ),
    );

    if (proceed == true) {
      // This takes the user to the system app settings page
      await openAppSettings();

      // After they come back, check again
      status = await Permission.locationAlways.status;
      return status.isGranted;
    }

    return false;
  }
}
