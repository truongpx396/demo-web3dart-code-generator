# Demo Web3Dart Code Generator

This simple project is to show how to work with Blockchain SmartContracts using web3dart code generator.

## Getting Started

A few dependencies need to be installed:

- [Web3Dart](https://pub.dev/packages/web3dart)
- [Web3Dart Builders](https://pub.dev/packages/web3dart_builders)
- [Web Socket Channel](https://pub.dev/packages/web_socket_channel)
- [Url Launcher](https://pub.dev/packages/url_launcher)

 Because `Code Generator` had been removed from `Web3Dart` after version 2.3.5, so we need to use `Web3Dart Builders` as dev dependencies for generating utility SmartContract code.
 
 The `pubspec.yaml` would be like the following.

```dart
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  web_socket_channel: ^2.0.0
  web3dart: ^2.6.1
  url_launcher: ^6.0.0-nullsafety

dev_dependencies:
  build_runner: ^2.1.8
  web3dart_builders: ^0.0.2
```
From `lib>contracts/token` we'll find `TokenContract.abi.json` file. The file contains ABI code in json format for certain SmartContract, This code lets outside world to know how to interact with SmartContract. 

Here we get the `ABI code` for TokenContract (Kind of `BEP20Token Standard` for defining every tokens on BSC Network, similar to `ERC20Token Standard` on Ethereum Network) and This code can be found here https://bscscan.com/address/0xe9e7cea3dedca5984780bafc599bd69add087d56#code

From this `TokenContract.abi.json` file we can use `Web3Dart Builder` to generate `TokenContract.g.dart` (The file containting generated utility code that lets us easily interact with SmartContract using dart code). To perform this, open the `Terminal` at root directory of project then running following code.

```dart
flutter pub run build_runner build --delete-conflicting-outputs
```


```dart
String web3HttpUrl = "https://nd-964-***-***.p2pify.com/***/";
String web3RdpUrl = "wss://ws-nd-964-***-***.p2pify.com/***/";

String walletPrivateKey = "YOUR_TEST_WALLET_PRIVATE_KEY";
String tokenContractAddress = "TOKEN_CONTRACT_ADDRESS";
String recipientAddress =
    "ADDRESS_TO_TEST_TRANSFER_TO";// Address to send coins, tokens to
```

```dart
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart';

 var web3Client = Web3Client(web3HttpUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(web3RdpUrl).cast<String>();
    });
```

```dart
import 'package:web3dart/web3dart.dart';

import '../contracts/token/TokenContract.g.dart';

TokenContract getTokenContract(String contracAddress) {
    return TokenContract(
        client: _web3Client,
        address: EthereumAddress.fromHex(contracAddress),
        chainId: 97);
  }
  
```

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
