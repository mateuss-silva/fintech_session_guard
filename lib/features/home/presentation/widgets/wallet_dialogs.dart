import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/features/home/domain/entities/withdraw_preview_entity.dart';

class WalletDialogs {
  static Future<void> showDepositDialog(
    BuildContext context, {
    required Function(double amount) onConfirm,
  }) async {
    await _showAmountDialog(
      context,
      title: 'Deposit Funds',
      actionText: 'Deposit',
      actionColor: AppColors.primary,
      onConfirm: onConfirm,
    );
  }

  static Future<void> showWithdrawDialog(
    BuildContext context, {
    required Function(double amount) onConfirm,
  }) async {
    await _showAmountDialog(
      context,
      title: 'Withdraw Funds',
      actionText: 'Withdraw',
      actionColor: AppColors.loss,
      onConfirm: onConfirm,
    );
  }

  static Future<void> _showAmountDialog(
    BuildContext context, {
    required String title,
    required String actionText,
    required Color actionColor,
    required Function(double amount) onConfirm,
  }) async {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                  ),
                  decoration: const InputDecoration(
                    prefixText: 'R\$ ',
                    prefixStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 24,
                    ),
                    hintText: '0.00',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) return 'Invalid amount';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final amount = double.parse(controller.text);
                  Navigator.pop(context);
                  onConfirm(amount);
                }
              },
              child: Text(
                actionText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showLiquidationConfirmationDialog(
    BuildContext context, {
    required double originalAmount,
    required List<AssetSoldPreviewEntity> assetsToSell,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Liquidation Required',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To withdraw R\$ ${originalAmount.toStringAsFixed(2)}, we need to automatically sell the following assets to cover the shortfall:',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    children: assetsToSell.map((asset) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          asset.ticker,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${asset.quantitySold.toStringAsFixed(4)} shares @ R\$ ${asset.priceAtExecution.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.textTertiary),
                        ),
                        trailing: Text(
                          'R\$ ${asset.valueGenerated.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.loss,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Do you wish to proceed with the sale and withdrawal?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.loss,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text(
                'Confirm & Sell',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
