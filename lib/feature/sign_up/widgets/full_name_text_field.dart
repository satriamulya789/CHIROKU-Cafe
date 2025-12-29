import 'package:flutter/widgets.dart';

class FullNameTextField extends StatelessWidget {
  final TextEditingController controller;

  const FullNameTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}