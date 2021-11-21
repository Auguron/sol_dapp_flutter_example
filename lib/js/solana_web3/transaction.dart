import 'dart:typed_data';
import 'package:js/js.dart';
import 'package:sol_dapp_flutter_test/js/solana_web3/public_key.dart';

@anonymous
@JS('wallet.solanaWeb3.AccountMeta')
class AccountMeta {
  external factory AccountMeta({PublicKey pubkey, bool isSigner, bool isWritable});
  external PublicKey get pubkey;
  external bool get isSigner;
  external bool get isWritable;
}

@anonymous
@JS('wallet.solanaWeb3.TransactionInstruction')
class TransactionInstruction {
  external factory TransactionInstruction(
      {PublicKey programId, Uint8List data, List<AccountMeta> keys});
}

@anonymous
@JS()
class FeePayer {
  external factory FeePayer({PublicKey feePayer});
}

@JS('wallet.solanaWeb3.Transaction')
class Transaction {
  external Transaction(FeePayer);
  external Transaction add(TransactionInstruction instruction);
  external Uint8List serialize();
  external set recentBlockhash(String value);
  external String get recentBlockhash;
}
