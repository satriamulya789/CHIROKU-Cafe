import 'package:get/get.dart';

class CashierBottomBarController extends GetxController {
  //================== Observables ===================//
  final selectedIndex = 0.obs;

  //================== Navigation Functions ===================//
  void changeIndex(int index) => selectedIndex.value = index;
}