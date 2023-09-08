import 'package:get/get.dart';
import 'package:machi_app/api/machi/purchases_api.dart';
import 'package:machi_app/datas/token_amount.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

TokenAccounting initial = TokenAccounting(
    subscribeTotal: 0,
    rewardTotal: 0,
    debitTotal: 0,
    creditTotal: 0,
    netCredits: 0);

/// Subscription controller tracks the tokens earned and used.
class SubscribeController extends GetxController {
  Rx<CustomerInfo?> _customer = (null).obs;
  // ignore: prefer_final_fields
  Rx<TokenAccounting> _token = initial.obs;

  CustomerInfo? get customer => _customer.value;
  set customer(CustomerInfo? value) => _customer.value = value!;

  TokenAccounting get token => _token.value;
  set token(TokenAccounting value) => _token.value = value;

  @override
  void onInit() async {
    super.onInit();
    initUser();
    _listenPurchases();
  }

  /// Get revenue cat's user info.
  void initUser() async {
    String userId = UserModel().user.userId;
    Purchases.logIn(userId).then((loginResult) async {
      CustomerInfo customer = await Purchases.getCustomerInfo();
      _customer = customer.obs;
    });
  }

  /// Get the credits the user current has.
  Future<int> getCredits() async {
    final purchaseApi = PurchasesApi();
    Map<String, dynamic> result = await purchaseApi.getCredits();
    TokenAccounting token = TokenAccounting.fromJson(result);

    _token.value = token;
    return token.netCredits;
  }

  /// Listens for any updates from customer purchases.
  void _listenPurchases() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _customer = customerInfo.obs;
    });
  }

  /// Add credits from purchasing and adjust the credit total.
  void addCredits(int qty) {
    int netTotal = token.netCredits + qty;
    int creditTotal = token.creditTotal + qty;
    _token.value =
        _token.value.copyWith(creditTotal: creditTotal, netCredits: netTotal);
  }

  /// Adds credits from earning via ads and adjust the rewards total.
  // void updateRewards(int qty) {
  //   int netTotal = token.netCredits + qty;
  //   int rewardTotal = token.rewardTotal + qty;
  //   _token.value =
  //       _token.value.copyWith(rewardTotal: rewardTotal, netCredits: netTotal);
  // }
}
