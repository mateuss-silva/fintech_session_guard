import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fintech_session_guard/core/di/injection.dart';
import 'package:fintech_session_guard/core/theme/app_colors.dart';
import 'package:fintech_session_guard/core/security/transaction_auth_helper.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_bloc.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';
import 'package:fintech_session_guard/features/trade/presentation/bloc/trade_bloc.dart';
import 'package:fintech_session_guard/features/trade/presentation/bloc/trade_event.dart';
import 'package:fintech_session_guard/features/trade/presentation/bloc/trade_state.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/wallet_dialogs.dart';

class TradeBottomSheet extends StatefulWidget {
  final String ticker;
  final String assetName;
  final double currentPrice;
  final bool hasPinConfigured;

  const TradeBottomSheet({
    super.key,
    required this.ticker,
    required this.assetName,
    required this.currentPrice,
    this.hasPinConfigured = true,
  });

  @override
  State<TradeBottomSheet> createState() => _TradeBottomSheetState();
}

class _TradeBottomSheetState extends State<TradeBottomSheet> {
  final TextEditingController _quantityController = TextEditingController();
  double _quantity = 0.0;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(() {
      setState(() {
        _quantity = double.tryParse(_quantityController.text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _executeTrade(BuildContext context, bool isBuy) {
    if (_quantity <= 0) return;

    if (isBuy) {
      context.read<TradeBloc>().add(
        TradeBuyRequested(ticker: widget.ticker, quantity: _quantity),
      );
    } else {
      context.read<TradeBloc>().add(
        TradeSellRequested(ticker: widget.ticker, quantity: _quantity),
      );
    }
  }

  Future<void> _handleAuthRequired(
    BuildContext context,
    TradeAuthRequired state,
  ) async {
    if (_isAuthenticating) return;
    _isAuthenticating = true;

    try {
      final authResult = await TransactionAuthHelper.authenticate(
        context,
        reason: 'Authenticate your trade for ${state.ticker}',
      );

      if (authResult.isAuthenticated && context.mounted) {
        final tradeBloc = context.read<TradeBloc>();
        if (state.isBuy) {
          tradeBloc.add(
            TradeBuyRequested(
              ticker: state.ticker,
              quantity: state.quantity,
              pin: authResult.pin,
              biometricToken: authResult.biometricToken,
            ),
          );
        } else {
          tradeBloc.add(
            TradeSellRequested(
              ticker: state.ticker,
              quantity: state.quantity,
              pin: authResult.pin,
              biometricToken: authResult.biometricToken,
            ),
          );
        }
      }
    } finally {
      _isAuthenticating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_US');
    final totalValue = _quantity * widget.currentPrice;

    return BlocProvider(
      create: (context) => sl<TradeBloc>(),
      child: BlocConsumer<TradeBloc, TradeState>(
        listener: (context, state) {
          if (state is TradeSuccess) {
            Navigator.of(context).pop(); // Close bottom sheet
            WalletDialogs.showSuccessDialog(context, state.message);
            // Refresh portfolio
            context.read<PortfolioBloc>().add(
              const PortfolioSummaryRequested(),
            );
          } else if (state is TradeFailure) {
            Navigator.of(context).pop(); // Close bottom sheet to show snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.loss,
              ),
            );
          } else if (state is TradeAuthRequired) {
            _handleAuthRequired(context, state);
          }
        },
        builder: (context, state) {
          final isLoading = state is TradeLoading;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ticker,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        Text(
                          widget.assetName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Current Price',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          currencyFormat.format(widget.currentPrice),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,4}'),
                    ),
                  ],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.numbers,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Value',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      currencyFormat.format(totalValue),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (!widget.hasPinConfigured)
                  _PinRequiredCard(ticker: widget.ticker)
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _quantity > 0
                              ? () => _executeTrade(context, false)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.loss,
                            disabledBackgroundColor: AppColors.cardColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'SELL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _quantity > 0
                              ? () => _executeTrade(context, true)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.cardColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'BUY',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Inline card shown inside the trade sheet when the user has no PIN configured.
class _PinRequiredCard extends StatelessWidget {
  final String ticker;

  const _PinRequiredCard({required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3D2000),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PIN required',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Set up a 4-digit PIN to buy or sell assets.',
                  style: TextStyle(color: Colors.amber, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // close the trade sheet first
              // The banner on the home page has the Set PIN button
            },
            child: const Text(
              'DISMISS',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
