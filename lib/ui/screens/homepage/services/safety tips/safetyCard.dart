import 'package:flutter/material.dart';

class SafetyCardButton extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;
  final Color? overlay;
  final LinearGradient? gradient;

  const SafetyCardButton({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
    this.overlay,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 10,
              spreadRadius: 4,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              if (gradient != null)
                Container(decoration: BoxDecoration(gradient: gradient))
              else if (overlay != null)
                Container(color: overlay),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}