# Demo Web3Dart Code Generator

This simple project is to show how to work with Blockchain SmartContracts using `Web3Dart Code Generator`.

![](https://github.com/truongpx396/demo-web3dart-code-generator/blob/master/images/test_result.png)

## Installing dependencies

A few dependencies need to be installed:

- [Web3Dart](https://pub.dev/packages/web3dart)
- [Web3Dart Builders](https://pub.dev/packages/web3dart_builders)
- [Web Socket Channel](https://pub.dev/packages/web_socket_channel)
- [Url Launcher](https://pub.dev/packages/url_launcher)

 Because `Code Generator` had been removed from `Web3Dart` after version 2.3.5, so we need to use `Web3Dart Builders` as dev dependency for generating utility SmartContract code.
 
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
## Generating utility SmartContract Code

From `lib>contracts/token` we'll find `TokenContract.abi.json` file. The file contains ABI code in json format for certain SmartContract, This code lets outside world to know how to interact with SmartContract. 

Here we get the `ABI code` for TokenContract (kind of `BEP20Token Standard` for defining every Tokens on BSC Network, similar to `ERC20Token Standard` on Ethereum Network) and This code can be found here https://bscscan.com/address/0xe9e7cea3dedca5984780bafc599bd69add087d56#code

From this `TokenContract.abi.json` file we can use `Web3Dart Builder` to generate `TokenContract.g.dart` (The file containting generated utility code that lets us easily interact with SmartContract using dart code). To perform this, open the `Terminal` at root directory of project then running following command.

```dart
flutter pub run build_runner build --delete-conflicting-outputs
```
After running the command, we'll see `TokenContract.g.dart` generated in the same folder with `TokenContract.abi.json`.

## Setting configurations

Necessary cofiguration parameters for the project can be found in `config_env.dart`

```dart
String web3HttpUrl = "https://nd-964-***-***.p2pify.com/***/";
String web3RdpUrl = "wss://ws-nd-964-***-***.p2pify.com/***/";

String walletPrivateKey = "YOUR_TEST_WALLET_PRIVATE_KEY";
String tokenContractAddress = "TOKEN_CONTRACT_ADDRESS";
String recipientAddress =
    "ADDRESS_TO_TEST_TRANSFER_TO";// Address to send coins, tokens to
```

The required parameters for web3Dart to connnect to certain Blockchain Network are `web3HttpUrl` and `web3RdpUrl`, To get these configuration parameters we can use the node service from https://chainstack.com/, navigate to https://docs.chainstack.com/quickstart/ follow the guidelines to create a new account, then create a new project and deploy a node pointing to `BSC Testnet` to get those config params.

Using your own test `walletPrivateKey` and `recipientAddress` to test interactions with SmartContracts, if you need some test BNB coins (native coins on BSC network) navigate to https://testnet.bnbchain.org/faucet-smart and paste in your wallet address.

For `tokenContractAddress` you can try with following deployed Token Contracts, or use your own Token Contracts deployed on `BSC Testnet`.

- `BUSD:` 0x69264a1a4fe2fbbc0a1c905f5d79f870931e3d69
- `USDT:` 0xf728066c846518417d2123d06bfbeeffe723387b
- `ETH:` 0xe35ec1d0cd973b313b6861d526488fd551112777
- `DAI:` 0xb6a15e5e795326306e9a8bc9611173cafb99dd37

## Initializing TokenContract instances

Create a web3Client instance that connects to BCS TestNet.

```dart
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart';

 var web3Client = Web3Client(web3HttpUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(web3RdpUrl).cast<String>();
    });
```

Using `web3Client` and `token contract address` to create a certain `TokenContact` instance, from this instance we can interact with every functions on token SmartContract.

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
## Interacting with SmartContracts

### Working with Native Coins

Native coins are coins tied to blockchain network (that helps fueling every actitvities on network like incentivizing network nodes, charging fees on transactions...), Every blockchain network has its own native coins, For BCS Blockchain (Binance Smart Chain) is BNB coin, For Ethereum Blockchain is ETH coin....

#### Get native balance of certain user wallet address.

```dart
import 'dart:async';
import 'package:web3dart/web3dart.dart';
import '../contracts/token/TokenContract.g.dart';

Future<double> getNativeBalance(String userAddress) async {
    var weiBalance =
        (await _web3Client.getBalance(EthereumAddress.fromHex(userAddress)))
            .getInWei;
    return CustomNumberFormatter.fromWeiToEthFormatted(weiBalance);
  }
```

#### Send native coins to certain address and listen to transfer completion event.

```dart
Future<String> transferNativeCoin(double amount, String toAddress,
      Function(String, String, double) onTransferCompleted) async {
    var transactionHash = await _web3Client.sendTransaction(
        _userWalletCredential,
        Transaction(
            to: EthereumAddress.fromHex(toAddress),
            maxGas: 100000,
            value: EtherAmount.inWei(
                CustomNumberFormatter.fromDoubleEthToWei(amount))),
        chainId: 97);
        
    //This periodically checks to see if certain transaction successfully processed
    reTryCheckingTransactionResult(
        web3Client: _web3Client,
        transactionHash: transactionHash,
        onTransactionSuccess: (receipt) {
          onTransferCompleted.call(
              _userWalletCredential.address.toString(), toAddress, amount);
        });

    return transactionHash;
  }
```

### Working with Tokens

Tokens are kind of special deployed smart contract, that represent certain crypto currency on network. Each token is specified by one respective smart contract.

#### Get token symbol.

```dart
Future<String> getTokenSymbol(String tokenContractAddress) async {
    var tokenContract = getTokenContract(tokenContractAddress);
    return await tokenContract.symbol();
  }
```
#### Get token balance.

```dart
Future<double> getTokenBalance(
      String userAddress, String tokenContractAddress) async {
    var tokenContract = getTokenContract(tokenContractAddress);
    var weiBalance =
        await tokenContract.balanceOf(EthereumAddress.fromHex(userAddress));
    return CustomNumberFormatter.fromWeiToEthFormatted(weiBalance);
  }
```
#### Transfer token and listen to transfer completion event.

```dart
Future<String> transferToken(
      String tokenContractAddress,
      double amount,
      String toAddress,
      Function(String, String, double) onTransferCompleted) async {
    var tokenContract = getTokenContract(tokenContractAddress);

    var recipientAddress = EthereumAddress.fromHex(toAddress);
    var amountToSend = CustomNumberFormatter.fromDoubleEthToWei(amount);

    //This listens to transferEvents from tokenContract to know when tokentransfer completed
    _tokenTransferSub = tokenContract.transferEvents().listen((event) {
      if (event.from == _userWalletCredential.address &&
          event.to == recipientAddress &&
          event.value == amountToSend) {
        onTransferCompleted.call(
            _userWalletCredential.address.toString(),
            recipientAddress.toString(),
            CustomNumberFormatter.fromWeiToEthFormatted(amountToSend));
        _tokenTransferSub.cancel();
      }
    });

    //This will return transactionHash
    return await tokenContract.transfer(recipientAddress, amountToSend,
        credentials: _userWalletCredential);
  }
```

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
