# Demo Web3Dart Code Generator

This simple project is to show how to work with Blockchain SmartContracts using web3dart code generator.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

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
