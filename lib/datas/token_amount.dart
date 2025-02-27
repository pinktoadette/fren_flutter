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
        subscribeTotal: doc[TOTAL_SUBSCRIBE_CREDITS] ?? 0,
        subscribedAt: doc[SUBSCRIBED_AT] != null
            ? DateTime.parse(doc[SUBSCRIBED_AT])
            : null,
        expiredDate: doc[EXPIRED_DATE] != null
            ? DateTime.parse(doc[EXPIRED_DATE])
            : null,
        rewardTotal: doc[TOTAL_REWARDS_CREDITS] ?? 0,
        debitTotal: doc[TOTAL_DEBIT] ?? 0,
        creditTotal: doc[TOTAL_CREDITS] ?? 0,
        netCredits: doc[NET_CREDITS] ?? 0);
  }
}
