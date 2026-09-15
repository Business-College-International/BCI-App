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
  late Future<WalletStatementView> _wallet;

  @override
  void initState() {
    super.initState();
    _wallet = _api.studentWallet(widget.ward.id);
  }

  void _retry() {
    setState(() => _wallet = _api.studentWallet(widget.ward.id));
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
                      const Text('The school has not yet enabled the final wallet ledger semantics for balance calculation. Transaction history is shown below without inventing a balance.'),
                    ],
                  ),
                ),
              ),
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
                    trailing: Text('GH₵ ${transaction.amount}'),
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
