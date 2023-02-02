import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

const BSC_EXPLORER = 'https://testnet.bscscan.com/tx/';

void exploreTransaction(String transHash) async {
  var url = '$BSC_EXPLORER$transHash';
  debugPrint("Exploring transaction: $url");
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void reTryCheckingTransactionResult(
    {required Web3Client web3Client,
    required String transactionHash,
    required Function(TransactionReceipt) onTransactionSuccess,
    Function? onTransactionFailed}) {
  reTry(function: () async {
    var trans = await web3Client.getTransactionReceipt(transactionHash);
    debugPrint("Transaction Hash: $transactionHash");
    debugPrint("Transaction status call after : $trans");
    if (trans != null) {
      if (trans.status!) {
        onTransactionSuccess.call(trans);
      } else {
        onTransactionFailed?.call(trans);
      }
      return true;
    } else {
      return false;
    }
  });
}

void reTry(
    {int currentTryIndex = 1,
    int tryCount = 30,
    required Function function}) async {
  await Future.delayed(const Duration(milliseconds: 1000));
  debugPrint(
    "===TryCount====> $currentTryIndex",
  );
  bool isSuccess;
  try {
    isSuccess = await function.call();
  } catch (_) {
    isSuccess = false;
  }
  tryCount = tryCount - 1;
  if (!isSuccess && tryCount > 0) {
    reTry(
        currentTryIndex: currentTryIndex + 1,
        tryCount: tryCount,
        function: function);
  }
}
