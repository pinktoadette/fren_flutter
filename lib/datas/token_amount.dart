import 'package:machi_app/constants/constants.dart';

class TokenAccounting {
  // "subscribeTotal": 0,
  // "subscribedAt": null,
  // "expiredDate": null,
  // "rewardTotal": 10,
  // "debitTotal": 1,
  // "netCredits": 9,
  // "creditTotal": 10

  int subscribeTotal;
  DateTime? subscribedAt;
  DateTime? expiredDate;
  int rewardTotal;
  int debitTotal;
  int creditTotal;
  int netCredits;

  TokenAccounting(
      {this.subscribeTotal = 0,
      this.subscribedAt,
      this.expiredDate,
      this.rewardTotal = 0,
      this.debitTotal = 0,
      this.creditTotal = 0,
      this.netCredits = 0});
  TokenAccounting copyWith({
    int? subscribeTotal,
    DateTime? subscribedAt,
    DateTime? expiredDate,
    int? rewardTotal,
    int? debitTotal,
    int? creditTotal,
    int? netCredits,
  }) {
    return TokenAccounting(
      subscribeTotal: subscribeTotal ?? this.subscribeTotal,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      expiredDate: expiredDate ?? this.expiredDate,
      rewardTotal: rewardTotal ?? this.rewardTotal,
      debitTotal: debitTotal ?? this.debitTotal,
      creditTotal: creditTotal ?? this.creditTotal,
      netCredits: netCredits ?? this.netCredits,
    );
  }

  factory TokenAccounting.fromJson(Map<String, dynamic> doc) {
    return TokenAccounting(
        subscribeTotal: doc[TOTAL_SUBSCRIBE_CREDITS],
        subscribedAt: doc[SUBSCRIBED_AT],
        expiredDate: doc[EXPIRED_DATE],
        rewardTotal: doc[TOTAL_REWARDS_CREDITS],
        debitTotal: doc[TOTAL_DEBIT],
        creditTotal: doc[TOTAL_CREDITS],
        netCredits: doc[NET_CREDITS]);
  }
}
