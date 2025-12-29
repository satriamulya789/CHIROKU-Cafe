import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding( 
        padding:EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/Logo.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Chiroku Café',
              style: TextStyle(
                fontSize: 40,
                fontFamily: GoogleFonts.montserrat().fontFamily,
                fontWeight: FontWeight.bold,
                color: Color(0xFF352C29),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            SizedBox(
              width: double.infinity, // buat tombol selebar kontainer (kanan-kiri)
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF004030),
                  foregroundColor: Color(0xFFE6E0DE),
                  elevation: 4,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text('Sign In'),
              ),
            ),
            SizedBox(height: 16),

            SizedBox(
              width: double.infinity, // buat tombol selebar kontainer (kanan-kiri)
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD2C8C4),
                  foregroundColor: Color(0xFF352C29),
                  elevation: 4,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text('Sign Up'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
