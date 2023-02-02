import 'dart:async';
import 'package:test_smartcontract/utils/contract_utils.dart';
import 'package:web3dart/web3dart.dart';

import '../contracts/token/TokenContract.g.dart';
import '../utils/custom_number_formatter.dart';

class TokensRepo {
  late Web3Client _web3Client;
  late Credentials _userWalletCredential;

  late StreamSubscription<Transfer> _tokenTransferSub;

  TokensRepo(Web3Client web3client, String walletPrivateKey) {
    _web3Client = web3client;
    //Import wallet by privateKey
    _userWalletCredential = EthPrivateKey.fromHex(walletPrivateKey);
  }

  String getCurrentWalletAddress() {
    return _userWalletCredential.address.toString();
  }

  TokenContract getTokenContract(String contracAddress) {
    return TokenContract(
        client: _web3Client,
        address: EthereumAddress.fromHex(contracAddress),
        chainId: 97);
  }

  Future<double> getNativeBalance(String userAddress) async {
    var weiBalance =
        (await _web3Client.getBalance(EthereumAddress.fromHex(userAddress)))
            .getInWei;
    return CustomNumberFormatter.fromWeiToEthFormatted(weiBalance);
  }

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

  Future<String> getTokenSymbol(String tokenContractAddress) async {
    var tokenContract = getTokenContract(tokenContractAddress);
    return await tokenContract.symbol();
  }

  Future<double> getTokenBalance(
      String userAddress, String tokenContractAddress) async {
    var tokenContract = getTokenContract(tokenContractAddress);
    var weiBalance =
        await tokenContract.balanceOf(EthereumAddress.fromHex(userAddress));
    return CustomNumberFormatter.fromWeiToEthFormatted(weiBalance);
  }

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
}
