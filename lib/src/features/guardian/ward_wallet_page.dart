import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/auth/auth_api.dart';
import '../../core/auth/auth_models.dart';
import 'wallet_models.dart';

class WardWalletPage extends StatefulWidget {
  const WardWalletPage({super.key, required this.ward});

  final WardView ward;

  @override
  State<WardWalletPage> createState() => _WardWalletPageState();
}

class _WardWalletPageState extends State<WardWalletPage> {
  final _api = AuthApi();
  final _amountController = TextEditingController();
  late Future<WalletStatementView> _wallet;
  String _network = 'MTN';
  String? _topUpIdempotencyKey;
  bool _topUpBusy = false;

  @override
  void initState() {
    super.initState();
    _wallet = _api.studentWallet(widget.ward.id);
  }

  void _retry() {
    setState(() => _wallet = _api.studentWallet(widget.ward.id));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _newIdempotencyKey(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _startWalletTopUp() async {
    final amount = _amountController.text.trim();
    final parsed = double.tryParse(amount);
    if (parsed == null || parsed <= 0) {
      _showMessage('Enter a valid top-up amount greater than zero.');
      return;
    }
    if (_topUpBusy) return;

    final key = _topUpIdempotencyKey ??= _newIdempotencyKey('bci-wallet-topup');
    setState(() => _topUpBusy = true);
    try {
      final result = await _api.initiateWalletTopUp(
        studentId: widget.ward.id,
        amount: amount,
        network: _network,
        idempotencyKey: key,
      );
      _topUpIdempotencyKey = null;
      if (!mounted) return;
      if (result.requiresOtp) {
        await _submitOtp(result);
      } else {
        _showTopUpResult(result);
      }
      _retry();
    } on DioException catch (error) {
      if (!mounted) return;
      final statusCode = error.response?.statusCode;
      if (statusCode == 400) {
        _topUpIdempotencyKey = null;
        _showMessage('The wallet top-up request was rejected. Correct the details and start a new attempt.');
      } else {
        _showMessage('The top-up outcome could not be confirmed. Do not start a second charge until the payment is reconciled.');
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('The top-up could not be completed. Check the payment status before starting another charge.');
    } finally {
      if (mounted) setState(() => _topUpBusy = false);
    }
  }

  Future<void> _submitOtp(WalletTopUpView initial) async {
    final controller = TextEditingController();
    try {
      final otp = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Confirm mobile-money payment'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'OTP',
              helperText: 'Enter the OTP sent for this wallet top-up.',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().length < 4) return;
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Submit OTP'),
            ),
          ],
        ),
      );
      if (otp == null || !mounted) return;

      try {
        final otpResult = await _api.submitWalletTopUpOtp(
          studentId: widget.ward.id,
          paymentId: initial.paymentId,
          otpCode: otp,
          network: initial.network ?? _network,
          sessionId: initial.sessionId,
          idempotencyKey: _newIdempotencyKey('bci-wallet-otp'),
        );
        if (!mounted) return;
        _showTopUpResult(otpResult);
      } on DioException {
        if (!mounted) return;
        _showMessage('OTP submission was not confirmed. The payment remains provider-controlled; check its status before trying another OTP.');
      } catch (_) {
        if (!mounted) return;
        _showMessage('OTP submission was not confirmed. Check the payment status before trying another OTP.');
      }
    } finally {
      controller.dispose();
    }
  }

  void _showTopUpResult(WalletTopUpView result) {
    final status = result.status == 'PROCESSING' ? 'processing' : result.status.toLowerCase();
    _showMessage('Wallet top-up of ${result.currency} ${result.amount} is $status. The balance changes only after verified provider settlement.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.ward.firstName} ${widget.ward.lastName} · Wallet')),
      body: FutureBuilder<WalletStatementView>(
        future: _wallet,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Wallet information could not be loaded.'),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _retry, child: const Text('Try again')),
                  ],
                ),
              ),
            );
          }

          final wallet = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Student wallet'),
                      const SizedBox(height: 6),
                      Text(
                        wallet.balance == null ? 'Balance pending ledger policy' : '${wallet.currency} ${wallet.balance}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(wallet.balanceStatus == 'CALCULATED'
                          ? 'This balance is derived from the signed wallet ledger.'
                          : 'A reliable balance is not available for this wallet yet. Transaction history is shown without inventing a balance.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.ward.canManageWallet) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add wallet funds', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 6),
                        const Text('Start a mobile-money top-up for this ward. The school credits the wallet only after verified provider settlement.'),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          enabled: !_topUpBusy,
                          decoration: const InputDecoration(labelText: 'Amount', prefixText: 'GH₵ '),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          key: ValueKey(_network),
                          initialValue: _network,
                          decoration: const InputDecoration(labelText: 'Mobile network'),
                          items: const [
                            DropdownMenuItem(value: 'MTN', child: Text('MTN')),
                            DropdownMenuItem(value: 'TELECEL', child: Text('Telecel')),
                            DropdownMenuItem(value: 'AIRTELTIGO', child: Text('AirtelTigo')),
                          ],
                          onChanged: _topUpBusy ? null : (value) => setState(() => _network = value ?? 'MTN'),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _topUpBusy ? null : _startWalletTopUp,
                            icon: _topUpBusy
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.account_balance_wallet_outlined),
                            label: Text(_topUpBusy ? 'Starting top-up…' : 'Start top-up'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text('Transactions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (wallet.transactions.isEmpty)
                const Card(child: ListTile(title: Text('No wallet transactions recorded.'))),
              ...wallet.transactions.map(
                (transaction) => Card(
                  child: ListTile(
                    title: Text(transaction.type),
                    subtitle: Text(
                      '${transaction.createdAt.toLocal().toString().split(' ').first}${transaction.note == null || transaction.note!.isEmpty ? '' : ' · ${transaction.note}'}',
                    ),
                    trailing: Text(
                      '${transaction.direction == 'DEBIT' ? '-' : transaction.direction == 'CREDIT' ? '+' : ''}GH₵ ${transaction.amount}',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}