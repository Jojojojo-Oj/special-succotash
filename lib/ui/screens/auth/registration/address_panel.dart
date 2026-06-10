import 'package:agapay_users/ui/screens/auth/registration/registration_model.dart';
import 'package:agapay_users/ui/widgets/TextFieldWidget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressPanel extends StatefulWidget {
  const AddressPanel({
    super.key,
    required this.controller,
    required this.data,
  });

  final PageController controller;
  final RegistrationData data;

  @override
  State<AddressPanel> createState() => _AddressPanelState();
}

class _AddressPanelState extends State<AddressPanel> {
  late TextEditingController regionController;
  late TextEditingController provinceController;
  late TextEditingController cityController;
  late TextEditingController barangayController;
  late TextEditingController sthController;

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    regionController = TextEditingController();
    provinceController = TextEditingController();
    cityController = TextEditingController();
    barangayController = TextEditingController();
    sthController = TextEditingController();

    regionController.addListener(_validateFields);
    provinceController.addListener(_validateFields);
    cityController.addListener(_validateFields);
    barangayController.addListener(_validateFields);
    sthController.addListener(_validateFields);
  }

  void _validateFields() {
    final isFilled = regionController.text.trim().isNotEmpty &&
        provinceController.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        barangayController.text.trim().isNotEmpty &&
        sthController.text.trim().isNotEmpty;

    if (isFilled != isButtonEnabled) {
      setState(() {
        isButtonEnabled = isFilled;
      });
    }
  }

  @override
  void dispose() {
    regionController.dispose();
    provinceController.dispose();
    cityController.dispose();
    barangayController.dispose();
    sthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 380;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 15),
                Text(
                  "What is your Address?",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Kindly provide your address as shown in the ID",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                _buildLabel("Region"),
                const SizedBox(height: 10),
                CustomTextinput(regionController, "Select Region", false),
                const SizedBox(height: 16),

                if (isNarrow) ...[
                  _buildLabel("Province"),
                  const SizedBox(height: 10),
                  CustomTextinput(provinceController, "Select Province", false),
                  const SizedBox(height: 16),
                  _buildLabel("City"),
                  const SizedBox(height: 10),
                  CustomTextinput(cityController, "Select City", false),
                ] else ...[
                  Row(
                    children: [
                      Expanded(child: _buildLabel("Province", leftPadding: 0)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildLabel("City", leftPadding: 0)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextinput(
                          provinceController,
                          "Select Province",
                          false,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: CustomTextinput(
                          cityController,
                          "Select City",
                          false,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                _buildLabel("Barangay"),
                const SizedBox(height: 10),
                CustomTextinput(barangayController, "Barangay", false),
                const SizedBox(height: 16),

                _buildLabel("Street / House No. / Building"),
                const SizedBox(height: 10),
                CustomTextinput(
                  sthController,
                  "House No / Building / Street / Village / Subd.",
                  false,
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: OutlinedButton(
                    onPressed: isButtonEnabled
                        ? () {
                            widget.data.region = regionController.text.trim();
                            widget.data.province = provinceController.text.trim();
                            widget.data.city = cityController.text.trim();
                            widget.data.brgy = barangayController.text.trim();
                            widget.data.streetHouseBuilding =
                                sthController.text.trim();

                            print("Full address: ${widget.data.fullAddress}");

                            widget.controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            );
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isButtonEnabled
                          ? const Color.fromARGB(255, 6, 37, 53)
                          : Colors.grey.shade400,
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(
    String text, {
    bool showAsterisk = true,
    double leftPadding = 20,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding, bottom: 4),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          if (showAsterisk)
            const Text(
              " *",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}
