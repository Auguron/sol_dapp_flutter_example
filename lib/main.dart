import 'dart:convert';
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_dapp_flutter_test/web_wallet.dart';

void main() {
  runApp(ProviderScope(child: const WidgetTree()));
}

class WidgetTree extends HookConsumerWidget {
  const WidgetTree();

  Widget _pleaseInstallPhantom() {
    return Center(child: Text("Please Install Phantom"));
  }

  Widget _pleaseConnectWallet(BuildContext context, WidgetRef ref) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Please Connect to Phantom"),
        SizedBox(height: 30),
        ElevatedButton(
          child: Text("Connect"),
          onPressed: () => ref.read(wallet.notifier).connectWallet(),
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pubkey = ref.watch(wallet);
    final browserHasPhantom = ref.watch(hasPhantom);
    // Determine what to show depending on Phantom wallet install/connection
    late String title;
    late Widget body;
    if (!browserHasPhantom) {
      title = "Please Install Phantom";
      body = _pleaseInstallPhantom();
    } else {
      if (pubkey != null) {
        title = "Solana Dapp Flutter Demo";
        body = const HomePage();
      } else {
        title = "Please Connect to Phantom";
        body = _pleaseConnectWallet(context, ref);
      }
    }
    return MaterialApp(
        title: 'Solana Dapp Flutter Demo',
        theme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(
            title: Text(title),
            //backgroundColor: Color.fromARGB(255, 78, 68, 206),
          ),
          body: body,
        ));
  }
}

class HomePage extends HookConsumerWidget {
  const HomePage();

  Widget _info(String title, String content, BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text("$title: ", style: Theme.of(context).textTheme.headline5),
      Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Theme.of(context).primaryColor,
          ),
          child: Text(content,
              overflow: TextOverflow.fade, style: Theme.of(context).textTheme.headline5))
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lamports = ref.watch(accountInfo).state?.lamports.toString() ?? '';
    final address = ref.watch(wallet)?.toBase58() ?? '';
    //final previousTx = ref.watch(previousTxid).state;
    final previousTx = useState('');
    final url = previousTx.value.isNotEmpty
        ? 'https://explorer.solana.com/tx/$previousTx?cluster=devnet'
        : '';
    final previousSignedPlaintext = useState('');
    return Container(
      padding: EdgeInsets.all(15),
      //constraints: BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _info("Address", address, context),
          SizedBox(height: 10),
          _info("Balance", lamports, context),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text("Airdrop"),
            onPressed: () => ref.read(wallet.notifier).requestAirdrop(),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            child: Text("Refresh Account Info"),
            onPressed: () => ref.read(wallet.notifier).refreshAccountInfo(),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            child: Text("Send Memo Transaction"),
            onPressed: () => ref
                .read(wallet.notifier)
                .confirmAndSendMemo("Hello world")
                .then((txid) => previousTx.value = txid),
          ),
          SizedBox(height: 10),
          _info("Previous Transaction", previousTx.value, context),
          SizedBox(height: 10),
          ElevatedButton(
              child: Text("View in Explorer: "),
              onPressed: () => url.isNotEmpty ? js.context.callMethod('open', [url]) : null),
          SizedBox(height: 30),
          _info("Previous Signed Message", previousSignedPlaintext.value, context),
          SizedBox(height: 10),
          ElevatedButton(
              child: Text("Sign utf8 plaintext"),
              onPressed: () => ref.read(wallet.notifier).signPlaintext("Hello world").then(
                  (signedMessage) =>
                      previousSignedPlaintext.value = base64.encode(signedMessage.signature)))
        ],
      ),
    );
  }
}
