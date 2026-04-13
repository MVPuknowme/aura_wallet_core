import '../type_data/wallet_gate_models.dart';

class WalletLedgerService {
  final List<WalletLedgerEntry> _entries = [];

  List<WalletLedgerEntry> get entries => List.unmodifiable(_entries);

  void record(WalletLedgerEntry entry) {
    _entries.add(entry);
  }
}
