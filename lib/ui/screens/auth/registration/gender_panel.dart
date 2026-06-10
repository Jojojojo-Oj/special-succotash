import 'package:agapay_users/ui/screens/auth/registration/registration_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GenderPanel extends StatefulWidget {
  const GenderPanel({super.key, required this.controller, required this.data});
  final PageController controller;
  final RegistrationData data;

  @override
  State<GenderPanel> createState() => _GenderPanelState();
}

class _GenderPanelState extends State<GenderPanel> {
  String? selectedGender;

  final List<Map<String, dynamic>> genders = [
    {'label': 'Male', 'icon': Icons.male},
    {'label': 'Female', 'icon': Icons.female},
    {'label': 'Non-Binary', 'icon': Icons.transgender},
    {'label': 'Others', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          Text(
            "What gender describes you?",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Select the gender identity that best represents you. This helps us tailor your profile.",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
       

  
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: genders.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final gender = genders[index];
              final bool isSelected = selectedGender == gender['label'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedGender = gender['label'];
                    widget.data.gender = selectedGender!; // ✅ Save to shared model
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE8F0FE) : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1A73E8)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      if (isSelected)
                        const Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(
                            Icons.check_circle,
                            color: Color(0xFF1A73E8),
                            size: 20,
                          ),
                        ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              gender['icon'],
                              size: 32,
                              color: isSelected
                                  ? const Color(0xFF1A73E8)
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              gender['label'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF1A73E8)
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 15,),

          SizedBox(
            width: 340,
            height: 65,
            child: OutlinedButton(
              onPressed: selectedGender == null
                  ? null
                  : () {
                      widget.controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      );
                    },
              style: OutlinedButton.styleFrom(
                backgroundColor: selectedGender == null
                    ? Colors.grey[400]
                    : const Color.fromARGB(255, 6, 37, 53),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "Next",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
