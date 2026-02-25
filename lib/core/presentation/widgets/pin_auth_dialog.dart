import 'package:flutter/material.dart';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../theme/app_colors.dart';

/// Reusable PIN authentication dialog.
///
/// Shows a dialog asking the user to enter their PIN and verifies it
/// against the backend. Returns the verified PIN string, or `null`
/// if cancelled.
class PinAuthDialog {
  PinAuthDialog._();

  /// Shows the PIN dialog and verifies the entered PIN.
  ///
  /// Returns the verified PIN [String] on success, or `null` if cancelled.
  static Future<String?> show(
    BuildContext context, {
    required String reason,
    required AuthRepository authRepository,
  }) async {
    final pinController = TextEditingController();
    String? errorText;

    final verifiedPin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Authentication Required',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reason,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Enter PIN',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  errorText: errorText,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.loss),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.loss),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final pin = pinController.text.trim();
                      if (pin.isEmpty) {
                        setDialogState(() => errorText = 'PIN is required');
                        return;
                      }

                      final result = await authRepository.verifyPin(pin);
                      result.fold((failure) {
                        setDialogState(() => errorText = failure.message);
                      }, (_) => Navigator.of(ctx).pop(pin));
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    pinController.dispose();
    return verifiedPin;
  }
}
