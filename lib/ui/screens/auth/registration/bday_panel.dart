import 'package:agapay_users/ui/screens/auth/registration/registration_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BdayPanel extends StatefulWidget {
  const BdayPanel({
    super.key,
    required this.controller,
    required this.data,
  });

  final PageController controller;
  final RegistrationData data;

  @override
  State<BdayPanel> createState() => _BdayPanelState();
}

class _BdayPanelState extends State<BdayPanel> {
  final TextEditingController _dateController = TextEditingController();
  bool isDateSelected = false;
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _dateController.text =
            "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
        isDateSelected = true;
      });
    }
  }

  void _onNext() {
    if (selectedDate != null) {
      widget.data.birthday = selectedDate;
    }

    widget.controller.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

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
            "When’s your birthday?",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Your birthdate helps confirm your identity securely.",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Label
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  "Date of Birth",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                " *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              )
            ],
          ),
          const SizedBox(height: 10),

          // Date input field
          SizedBox(
            width: 340,
            child: TextField(
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                hintText: 'Birthdate',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                suffixIcon: IconButton(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black54),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Next button
          SizedBox(
            width: 340,
            height: 65,
            child: OutlinedButton(
              onPressed: isDateSelected ? _onNext : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: isDateSelected
                    ? const Color.fromARGB(255, 6, 37, 53)
                    : Colors.grey[400],
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
