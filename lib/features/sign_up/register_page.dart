import 'package:chiroku_cafe/features/sign_up/controllers/signup_controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is bound (use binding in route) or put here:
    if (!Get.isRegistered<RegisterController>()) {
      Get.put(RegisterController());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar', style: GoogleFonts.montserrat()),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.coffee, size: 80),
                  const SizedBox(height: 12),
                  Text('Chiroku Cafe',
                      style: GoogleFonts.montserrat(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  Obx(() {
                    if (controller.statusMessage.value != null) {
                      return Column(children: [
                        Text(controller.statusMessage.value!,
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                      ]);
                    }
                    return const SizedBox.shrink();
                  }),
                  TextFormField(
                    controller: controller.fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: const Icon(Icons.person_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: controller.validateFullName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.validateEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: true,
                    validator: controller.validatePassword,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 12),
                  // Role selection (optional)
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => RadioListTile<String>(
                              value: 'cashier',
                              groupValue: controller.role.value,
                              onChanged: (v) {
                                if (v != null) controller.setRole(v);
                              },
                              title: const Text('Cashier'),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.register,
                        style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Daftar',
                                style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                      )),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun? ',
                          style: GoogleFonts.montserrat(fontSize: 14)),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text('Masuk',
                            style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}