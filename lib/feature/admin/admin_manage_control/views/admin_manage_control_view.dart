import 'package:chiroku_cafe/config/routes/routes.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/controllers/admin_manage_control_controller.dart';
import 'package:chiroku_cafe/feature/admin/admin_manage_control/widgets/admin_manage_control_tab_bar_widget.dart';
import 'package:chiroku_cafe/shared/style/app_color.dart';
import 'package:chiroku_cafe/shared/style/google_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminManageControlView extends GetView<AdminManageControlController> {
  const AdminManageControlView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownLight,
      body: Column(
        children: [
          _buildAppBar(),
          AdminTabBar(controller: controller),
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              children: [
                _buildUserPage(),
                _buildMenuPage(),
                _buildCategoryPage(),
                _buildTablePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.brownLight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Manage Control',
                      style: AppTypography.h5.copyWith(
                        color: AppColors.brownDarker,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swipe,
                          color: AppColors.brownDarker.withOpacity(0.7),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Swipe to navigate',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.brownDarker
                            .withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  // USER PAGE
  Widget _buildUserPage() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMainCard(
                  title: 'Manage Users',
                  icon: Icons.people,
                  description: 'Add, edit, or remove users',
                  onTap: () => Get.toNamed(AppRoutes.adminEditUser),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Manage all users in the system. You can add new users, edit existing user information, change roles, or remove users from the system.',
                ),
                const SizedBox(height: 16),
                _buildStatsCard(
                  icon: Icons.person,
                  title: 'Total Users',
                  value: '0',
                  subtitle: 'Registered users',
                  color: AppColors.brownNormal,
                ),
              ],
            ),
          ),
        ),
        _buildAddButton(
          label: 'Add New User',
          icon: Icons.person_add,
          onPressed: () => Get.toNamed(AppRoutes.adminEditUser),
        ),
      ],
    );
  }

  // MENU PAGE
  Widget _buildMenuPage() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMainCard(
                  title: 'Manage Menus',
                  icon: Icons.restaurant_menu,
                  description: 'Add, edit, or remove menu items',
                  onTap: () => Get.toNamed(AppRoutes.adminEditMenu),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Manage your menu items. Add new dishes, update prices and descriptions, upload menu images, or remove items that are no longer available.',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatsCard(
                        icon: Icons.restaurant,
                        title: 'Total Menus',
                        value: '0',
                        subtitle: 'Menu items',
                        color: AppColors.brownNormal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatsCard(
                        icon: Icons.check_circle,
                        title: 'Available',
                        value: '0',
                        subtitle: 'In stock',
                        color: AppColors.successNormal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _buildAddButton(
          label: 'Add New Menu',
          icon: Icons.add_circle,
          onPressed: () => Get.toNamed(AppRoutes.adminAddMenu),
        ),
      ],
    );
  }

  // CATEGORY PAGE
  Widget _buildCategoryPage() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMainCard(
                  title: 'Manage Categories',
                  icon: Icons.category,
                  description: 'Add, edit, or remove categories',
                  onTap: () => Get.toNamed(AppRoutes.adminEditCategory),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Organize your menu by categories. Create new categories for better menu organization, edit category names, or remove unused categories.',
                ),
                const SizedBox(height: 16),
                _buildStatsCard(
                  icon: Icons.folder,
                  title: 'Total Categories',
                  value: '0',
                  subtitle: 'Menu categories',
                  color: AppColors.brownNormal,
                ),
              ],
            ),
          ),
        ),
        _buildAddButton(
          label: 'Add New Category',
          icon: Icons.create_new_folder,
          onPressed: () => Get.toNamed(AppRoutes.adminEditCategory),
        ),
      ],
    );
  }

  // TABLE PAGE
  Widget _buildTablePage() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMainCard(
                  title: 'Manage Tables',
                  icon: Icons.table_restaurant,
                  description: 'Add, edit, or remove tables',
                  onTap: () => Get.toNamed(AppRoutes.adminEditTable),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Manage table settings. Add new tables, update table information like capacity and status, or remove tables that are no longer in use.',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatsCard(
                        icon: Icons.table_bar,
                        title: 'Total Tables',
                        value: '0',
                        subtitle: 'Tables',
                        color: AppColors.brownNormal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatsCard(
                        icon: Icons.event_available,
                        title: 'Available',
                        value: '0',
                        subtitle: 'Ready',
                        color: AppColors.successNormal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _buildAddButton(
          label: 'Add New Table',
          icon: Icons.add_business,
          onPressed: () => Get.toNamed(AppRoutes.adminEditTable),
        ),
      ],
    );
  }

  Widget _buildMainCard({
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.brownNormal,
              AppColors.brownDark,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.brownDark.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h6.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String info) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brownNormal.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.brownNormal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Information',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.brownDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            info,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.brownNormal,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.brownDark,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.brownNormal.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brownNormal,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }
}