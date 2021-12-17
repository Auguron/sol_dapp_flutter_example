import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:sol_dapp_flutter_test/js/solana_web3/fee_calculator.dart';
import 'package:sol_dapp_flutter_test/js/solana_web3/public_key.dart';

@JS('wallet.solanaWeb3.clusterApiUrl')
external String clusterApiUrl(String network);

@anonymous
@JS()
class GetRecentBlockhashResponse {
  external factory GetRecentBlockhashResponse({String blockhash, FeeCalculator feeCalculator});
  external String get blockhash;
  external FeeCalculator get feeCalculator;
}

@JS('wallet.solanaWeb3.Connection')
class Connection {
  external Connection(String url);
  external Future<AccountInfo?> getAccountInfo(PublicKey publicKey, String? commitment);
  external Future<GetRecentBlockhashResponse> getRecentBlockhash();
  external Future<String> sendRawTransaction(Uint8List rawTransaction);
  external Future<String> requestAirdrop(PublicKey to, int lamports);
  external Future<dynamic> confirmTransaction(String signature);
}

@anonymous
@JS('wallet.solanaWeb3.AccountInfo')
class AccountInfo {
  external factory AccountInfo({int lamports, bool executable, PublicKey owner, dynamic data});
  external int get lamports;
  external PublicKey get owner;
  external bool get executable;
  external dynamic get data;
}
