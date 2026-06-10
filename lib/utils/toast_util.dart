import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ToastHelper {
  /// ✅ Success Toast (Green)
  static void showSuccess(BuildContext context, String message) {
    DelightToastBar(
      autoDismiss: true,
      animationDuration: Duration(milliseconds: 300),
      snackbarDuration: Duration(seconds: 2),   
      builder: (context) => ToastCard(
        leading: const Icon(Icons.check_circle, color: Colors.green, size: 32),
        title: Text("SUCCESS", style:  GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
        subtitle: Text(message, style:  GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.white70),),
        color: Colors.green.shade700,
      ),
    ).show(context);
  }

  /// ❌ Error Toast (Red)
  static void showError(BuildContext context, String message) {
    DelightToastBar(
      autoDismiss: true,
      animationDuration: Duration(milliseconds: 300),
      snackbarDuration: Duration(seconds: 2),
      builder: (context) => ToastCard(
        leading: const Icon(Icons.error, color: Colors.red, size: 28),
        title: Text("FAILED", style:  GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
        subtitle: Text(message, style:  GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.white70),),
        color: Colors.red.shade700,
      ),
    ).show(context);
  }

  /// ℹ️ Info Toast (Blue)
  static void showInfo(BuildContext context, String message) {
    DelightToastBar(
      builder: (context) => ToastCard(
        leading: const Icon(Icons.info, color: Colors.blue, size: 28),
        title: const Text(
          "Info",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        color: Colors.blue.shade600,
      ),
    ).show(context);
  }
}
