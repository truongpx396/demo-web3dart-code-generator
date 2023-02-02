import 'dart:math';

import 'package:web3dart/web3dart.dart';

//1 eth = 10^18 wei
class CustomNumberFormatter {
  static double fromWeiToEthFormatted(BigInt weiAmount) {
    return EtherAmount.fromBigInt(EtherUnit.wei, weiAmount)
        .getValueInUnit(EtherUnit.ether);
  }

  static BigInt fromDoubleEthToWei(double value) {
    return BigInt.from(value * pow(10, 18));
  }
}
