import 'package:flutter/material.dart';
import 'package:test_smartcontract/config_env.dart';
import 'package:test_smartcontract/repo/tokens_repo.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'utils/contract_utils.dart';
import 'package:http/http.dart';

// Running below command in Terminal for web3dart_builders to generate .g.dart from .abi.json files
// flutter pub run build_runner build --delete-conflicting-outputs
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Demo Web3Dart Generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TokensRepo _tokensRepo;

  late String _tokenContractAddress;
  late String _recipientAddress;

  String _walletAddress = "";
  String _nativeBalance = "";
  String _tokenSymbol = "";
  String _tokenBalance = "";
  String _currentTransactionHash = "";
  String _transferResult = "";

  @override
  void initState() {
    super.initState();

    var web3Client = Web3Client(web3HttpUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(web3RdpUrl).cast<String>();
    });

    _tokensRepo = TokensRepo(web3Client, walletPrivateKey);
    _tokenContractAddress = tokenContractAddress;
    _recipientAddress = recipientAddress;

    _loadWalletInfo();
  }

  void _loadWalletInfo() async {
    _walletAddress = _tokensRepo.getCurrentWalletAddress();
    _nativeBalance =
        (await _tokensRepo.getNativeBalance(_walletAddress)).toString();
    _tokenSymbol = await _tokensRepo.getTokenSymbol(_tokenContractAddress);
    _tokenBalance = (await _tokensRepo.getTokenBalance(
            _walletAddress, _tokenContractAddress))
        .toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "WalletAddress",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_walletAddress),
            _buildTextInfo('Native Balance: ', '$_nativeBalance BNB'),
            _buildTextInfo('Token Symbol: ', _tokenSymbol),
            _buildTextInfo('Token Balance: ', _tokenBalance),
            const Text(
              '--------------------------------',
            ),
            _buildTextInfo(
                'Current TransactionHash: ', _currentTransactionHash),
            const SizedBox(
              height: 10,
            ),
            _buildTextInfo('TransferResult: ', _transferResult),
            const SizedBox(
              height: 10,
            ),
            Visibility(
              visible: _currentTransactionHash != "" &&
                  _currentTransactionHash != "submitting...",
              child: TextButton(
                  onPressed: () {
                    exploreTransaction(_currentTransactionHash);
                  },
                  child: const Text("Check on BSC Explorer")),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() async {
          _currentTransactionHash = "submitting...";
          _transferResult = "...";
          setState(() {});

          _currentTransactionHash = await _tokensRepo
              .transferNativeCoin(0.005, _recipientAddress, (from, to, amount) {
            _transferResult =
                ">>>>>>> Transfer Completed! {FROM}: $from {TO}: $to {AMOUNT}: $amount";
            debugPrint(_transferResult);
            _loadWalletInfo();
          });

          // _currentTransactionHash = await _tokensRepo.transferToken(
          //     _tokenContractAddress,
          //     50.55,
          //     _receipientAddress, (from, to, amount) {
          //   _transferResult =
          //       ">>>>>>> TransferCompleted! From: $from To: $to Amount: $amount";
          //   debugPrint(_transferResult);
          //   _loadWalletInfo();
          // });

          _transferResult = "confirming...";
          setState(() {});
        }),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildTextInfo(String title, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
