import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Full-screen confetti celebration dialog that auto-dismisses after [duration].
///
/// Show it after a PIN is successfully configured:
/// ```dart
/// await PinSuccessDialog.show(context);
/// ```
class PinSuccessDialog extends StatefulWidget {
  final Duration duration;

  const PinSuccessDialog({
    super.key,
    this.duration = const Duration(seconds: 3),
  });

  /// Convenience method — shows the dialog and waits for it to auto-dismiss.
  static Future<void> show(
    BuildContext context, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => PinSuccessDialog(duration: duration),
    );
  }

  @override
  State<PinSuccessDialog> createState() => _PinSuccessDialogState();
}

class _PinSuccessDialogState extends State<PinSuccessDialog>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final AnimationController _scaleController;
  late final Animation<double> _scale;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(duration: widget.duration)..play();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();

    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Confetti blasting from top-center
        Positioned(
          top: 0,
          left: MediaQuery.of(context).size.width / 2,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            gravity: 0.3,
            emissionFrequency: 0.05,
            colors: const [
              AppColors.primary,
              Color(0xFF3B82F6),
              Color(0xFF8B5CF6),
              Colors.amber,
              Colors.pink,
            ],
          ),
        ),

        // Center card
        ScaleTransition(
          scale: _scale,
          child: Dialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF00B4D8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_open_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PIN Configured! 🎉',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your transactions are now\nprotected by your PIN.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _CountdownBar(duration: widget.duration),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated progress bar that drains over [duration].
class _CountdownBar extends StatefulWidget {
  final Duration duration;

  const _CountdownBar({required this.duration});

  @override
  State<_CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<_CountdownBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: 1 - _controller.value,
          backgroundColor: AppColors.surfaceLight,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),
      ),
    );
  }
}
