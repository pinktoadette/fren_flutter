import 'package:get/get.dart';
import 'package:machi_app/api/machi/subscribe_api.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

//@todo remove scope model to getX
class SubscribeController extends GetxController {
  late Rx<CustomerInfo> _customer;
  RxInt credits = 0.obs;

  CustomerInfo get customer => _customer.value;
  set customer(CustomerInfo value) => _customer.value = value;

  @override
  void onInit() async {
    initUser();
    _listenPurchases();
    super.onInit();
  }

  void initUser() async {
    CustomerInfo customer = await Purchases.getCustomerInfo();
    _customer = customer.obs;
  }

  void _getCredits() async {
    final _subscribeApi = SubscribesApi();
    Map<String, dynamic> result = await _subscribeApi.getUserSubscription();
    credits = result["credits"] ?? 0;
  }

  void _listenPurchases() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _customer = customerInfo.obs;
      _getCredits();
    });
  }
}
