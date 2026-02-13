import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_theme.dart';

/// Dialog for PIN entry. Returns the PIN string if confirmed, or null if cancelled.
class PinInputDialog extends StatefulWidget {
  final String title;
  const PinInputDialog({super.key, this.title = 'Enter PIN'});

  static Future<String?> show(
    BuildContext context, {
    String title = 'Enter PIN',
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PinInputDialog(title: title),
    );
  }

  @override
  State<PinInputDialog> createState() => _PinInputDialogState();
}

class _PinInputDialogState extends State<PinInputDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorder),
      ),
    );

    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Authenticate to proceed',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Pinput(
            length: 4,
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration!.copyWith(
                border: Border.all(color: AppTheme.primary),
              ),
            ),
            obscureText: true,
            onCompleted: (pin) {
              Navigator.of(context).pop(pin);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
