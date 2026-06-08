import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

class PermissionHelper {
  static const _background = Color(0xFF101415);
  static const _card = Color(0xE61A2021);
  static const _lime = Color(0xFFB6FF00);
  static const _textMuted = Color(0xFFD0D6C9);

  static Future<bool> requestBackgroundLocationPermission(
      BuildContext context,
      ) async {
    final location = Location();

    var serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();

      if (!serviceEnabled) {
        return false;
      }
    }

    var permissionStatus = await location.hasPermission();

    if (permissionStatus == PermissionStatus.granted ||
        permissionStatus == PermissionStatus.grantedLimited) {
      return true;
    }

    permissionStatus = await location.requestPermission();

    if (permissionStatus == PermissionStatus.granted ||
        permissionStatus == PermissionStatus.grantedLimited) {
      return true;
    }

    if (!context.mounted) return false;

    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x383BEA72)),
            boxShadow: const [
              BoxShadow(
                color: Color(0xAA030607),
                blurRadius: 28,
                offset: Offset(0, 16),
              ),
              BoxShadow(color: Color(0x3335F46E), blurRadius: 24),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_card, _background],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334D12),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Color(0x6635F46E), blurRadius: 18),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_searching,
                      color: _lime,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Taustal jälgimine',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Rakendus vajab taustal asukoha õigust, et marsruuti jälgida ka siis, kui ekraan on lukustatud.',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 15,
                  height: 1.38,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textMuted,
                        side: const BorderSide(color: Color(0x33FFFFFF)),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: const Text('Tühista'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: _lime,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(48),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: const Text('Ava seaded'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (proceed == true) {
      await permission_handler.openAppSettings();

      await Future.delayed(const Duration(seconds: 1));

      permissionStatus = await location.hasPermission();

      return permissionStatus == PermissionStatus.granted ||
          permissionStatus == PermissionStatus.grantedLimited;
    }

    return false;
  }

  static Future<bool> requestActivityRecognitionPermission() async {
    var status =
    await permission_handler.Permission.activityRecognition.status;

    if (status.isGranted) {
      return true;
    }

    status = await permission_handler.Permission.activityRecognition.request();
    return status.isGranted;
  }
}