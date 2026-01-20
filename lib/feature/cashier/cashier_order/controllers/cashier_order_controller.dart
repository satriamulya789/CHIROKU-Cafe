import 'package:chiroku_cafe/feature/cashier/cashier_order/repositories/cashier_order_menu_repositories.dart';
import 'package:get/get.dart';
import '../models/cashier_order_category_model.dart';
import '../models/cashier_order_menu_model.dart';

class OrderController extends GetxController {
  final MenuRepository _repo = MenuRepository();

  final RxList<CategoryMenuModel> categories = <CategoryMenuModel>[].obs;
  final RxList<MenuModel> menus = <MenuModel>[].obs;
  final RxList<MenuModel> filteredMenus = <MenuModel>[].obs;

  final RxString selectedCategory = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      print('🔄 Loading categories and menus...');

      final cats = await _repo.getCategories();
      final mns = await _repo.getMenus();

      print('✅ Categories loaded: ${cats.length}');
      print('✅ Menus loaded: ${mns.length}');

      categories.assignAll(cats);
      menus.assignAll(mns);

      print('📋 Categories: ${categories.map((c) => c.name).toList()}');
      print('📋 Menus: ${menus.map((m) => m.name).toList()}');

      filterMenus();

      print('🔍 Filtered menus: ${filteredMenus.length}');
    } catch (e, stackTrace) {
      print('❌ Error loading data: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load menu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterMenus() {
    final query = searchQuery.value.toLowerCase();
    final cat = selectedCategory.value;
    
    print('🔍 Filtering - Query: "$query", Category: "$cat"');
    print('🔍 Total menus before filter: ${menus.length}');
    
    filteredMenus.assignAll(
      menus.where((menu) {
        final matchCat =
            cat == 'all' ||
            (menu.category?.name.toLowerCase() == cat.toLowerCase());
        final matchSearch =
            query.isEmpty || menu.name.toLowerCase().contains(query);
        
        if (!matchCat || !matchSearch) {
          print('❌ Menu "${menu.name}" filtered out - matchCat: $matchCat, matchSearch: $matchSearch, category: ${menu.category?.name}');
        }
        
        return matchCat && matchSearch;
      }).toList(),
    );
    
    print('✅ Filtered menus count: ${filteredMenus.length}');
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterMenus();
  }

  void setSelectedCategory(String cat) {
    selectedCategory.value = cat;
    filterMenus();
  }

  void clearSearch() {
    searchQuery.value = '';
    filterMenus();
  }
}
