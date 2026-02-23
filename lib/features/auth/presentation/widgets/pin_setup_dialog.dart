import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'pin_success_dialog.dart';

/// Two-step PIN setup dialog: enter new PIN, then confirm it.
/// Dispatches [AuthSetPinRequested] on the [AuthBloc] when confirmed.
class PinSetupDialog extends StatefulWidget {
  const PinSetupDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const PinSetupDialog(),
      ),
    );
    return result ?? false;
  }

  @override
  State<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<PinSetupDialog> {
  final _pin1Controller = TextEditingController();
  final _pin2Controller = TextEditingController();
  String? _firstPin;
  String? _errorText;

  bool get _isConfirmStep => _firstPin != null;

  @override
  void dispose() {
    _pin1Controller.dispose();
    _pin2Controller.dispose();
    super.dispose();
  }

  PinTheme get _defaultTheme => PinTheme(
    width: 52,
    height: 52,
    textStyle: const TextStyle(
      fontSize: 20,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.cardBorder),
    ),
  );

  void _onPinEntered(String pin) {
    if (!_isConfirmStep) {
      setState(() {
        _firstPin = pin;
        _errorText = null;
        _pin1Controller.clear();
      });
    } else {
      if (pin == _firstPin) {
        context.read<AuthBloc>().add(AuthSetPinRequested(pin));
      } else {
        setState(() {
          _errorText = 'PINs do not match. Try again.';
          _firstPin = null;
          _pin1Controller.clear();
          _pin2Controller.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthPinSetSuccess) {
          // Close the setup dialog, then show the confetti celebration
          Navigator.of(context).pop(true);
          await PinSuccessDialog.show(context);
        } else if (state is AuthPinSetFailure) {
          setState(() {
            _errorText = state.message;
            _firstPin = null;
            _pin1Controller.clear();
            _pin2Controller.clear();
          });
        }
      },
      child: AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _isConfirmStep ? 'Confirm PIN' : 'Create PIN',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isConfirmStep
                  ? 'Re-enter your PIN to confirm'
                  : 'Choose a 4-digit PIN for transactions',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Pinput(
              key: ValueKey(_isConfirmStep),
              length: 4,
              controller: _isConfirmStep ? _pin2Controller : _pin1Controller,
              autofocus: true,
              defaultPinTheme: _defaultTheme,
              focusedPinTheme: _defaultTheme.copyWith(
                decoration: _defaultTheme.decoration!.copyWith(
                  border: Border.all(color: AppColors.primary),
                ),
              ),
              errorPinTheme: _defaultTheme.copyWith(
                decoration: _defaultTheme.decoration!.copyWith(
                  border: Border.all(color: AppColors.loss),
                ),
              ),
              obscureText: true,
              onCompleted: _onPinEntered,
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(color: AppColors.loss, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          if (_isConfirmStep)
            TextButton(
              onPressed: () {
                setState(() {
                  _firstPin = null;
                  _errorText = null;
                  _pin1Controller.clear();
                });
              },
              child: const Text(
                'Back',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
