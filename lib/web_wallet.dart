import 'dart:typed_data';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:js/js_util.dart';
import 'package:sol_dapp_flutter_test/js/solana_web3/connection.dart' as conn;
import 'package:sol_dapp_flutter_test/js/solana_web3/public_key.dart';
import 'package:sol_dapp_flutter_test/js/solana_web3/transaction.dart';
import 'package:sol_dapp_flutter_test/js/phantom.dart' as phantom;
import 'dart:convert' show utf8;

final accountInfo = StateProvider<conn.AccountInfo?>((ref) => null);
final hasPhantom = Provider<bool>((ref) => phantom.isPhantomInstalled() ?? false);

/// Access Service classes through Provider for singleton and mocking
final wallet = StateNotifierProvider<WebWallet, PublicKey?>((ref) => WebWallet(ref.read));

/// All our Solana-related stuff
class WebWallet extends StateNotifier<PublicKey?> {
  Reader read;
  // Hardcoding devnet
  final _conn = conn.Connection(conn.clusterApiUrl('devnet'));

  WebWallet(this.read) : super(null);

  Future<PublicKey> connectWallet() async {
    print("Connecting wallet...");
    if (!read(hasPhantom)) {
      throw Exception("Phantom is not installed");
    }
    final pubkey = await promiseToFuture(phantom.connect());
    state = pubkey;
    refreshAccountInfo();
    return pubkey;
  }

  /// Create a transaction from scratch, sign with Phantom, send it.
  Future<String> confirmAndSendMemo(String msg) async {
    // Prepare a tx instruction
    final meta = [AccountMeta(pubkey: state!, isSigner: true, isWritable: false)];
    final memoProgram = PublicKey("MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr");
    final data = Uint8List.fromList(utf8.encode(msg));
    final instruction = TransactionInstruction(data: data, programId: memoProgram, keys: meta);
    // Add it to a new tx
    final tx = Transaction(FeePayer(feePayer: state!));
    tx.add(instruction);
    // Fetch and assign a recent blockhash, request signature
    final recentBlockhash = await promiseToFuture(_conn.getRecentBlockhash());
    tx.recentBlockhash = recentBlockhash.blockhash;
    final signed = await promiseToFuture(phantom.signTransaction(tx));
    // Serialize and send
    final serialized = signed.serialize();
    final txid = await promiseToFuture(_conn.sendRawTransaction(serialized));
    return txid;
  }

  Future<conn.AccountInfo> refreshAccountInfo() async {
    conn.AccountInfo? info = await promiseToFuture(_conn.getAccountInfo(state!, null));
    if (info == null) {
      final txid = await _conn.requestAirdrop(state!, 100000000);
      await _conn.confirmTransaction(txid);
    }
    info = await promiseToFuture(_conn.getAccountInfo(state!, null));
    if (info == null) {
      throw Exception("Invalid address, could not locate balance or perform airdrop");
    }
    read(accountInfo).state = info;
    return info;
  }

  Future<void> requestAirdrop({int lamports: 1000000000}) async {
    await _conn.requestAirdrop(state!, lamports);
  }

  Future<phantom.SignedMessage> signPlaintext(String plaintext) async {
    return await promiseToFuture(phantom.signMessage(plaintext));
  }
}
