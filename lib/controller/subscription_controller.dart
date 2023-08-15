import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/purchases_api.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

//@todo remove scope model to getX
class SubscribeController extends GetxController {
  Rx<CustomerInfo?> _customer = (null).obs;
  RxInt credits = 0.obs;

  CustomerInfo? get customer => _customer.value;
  set customer(CustomerInfo? value) => _customer.value = value!;

  @override
  void onInit() async {
    super.onInit();
    _listenPurchases();
  }

  void initUser() async {
    String userId = UserModel().user.userId;
    Purchases.logIn(userId).then((loginResult) async {
      CustomerInfo customer = await Purchases.getCustomerInfo();
      _customer = customer.obs;
    });
  }

  void getCredits() async {
    final purchaseApi = PurchasesApi();
    Map<String, dynamic> result = await purchaseApi.getCredits();
    credits.value = result["credit"] ?? 0;
    debugPrint("${credits.value.toString()} credits ");
  }

  void _listenPurchases() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _customer = customerInfo.obs;
    });
  }

  void updateCredits(int qty) {
    credits.value = qty;
  }
}
