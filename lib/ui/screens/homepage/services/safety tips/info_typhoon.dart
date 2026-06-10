import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class InfoTyphoonPage extends StatefulWidget {
  const InfoTyphoonPage({super.key});

  @override
  State<InfoTyphoonPage> createState() => _InfoTyphoonPageState();
}

class _InfoTyphoonPageState extends State<InfoTyphoonPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
        children: [        
          Column(
            children: [
           
              Stack(
                children: [
                  Image.asset(
                    'assets/images/typhoon.gif',
                    width: double.infinity,
                    height: 230,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: double.infinity,
                    height: 230,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'TYPHOON',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Color(0xFF9AD1FF),
                              fontSize: 53,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              height: 1.9,
                            ),
                          ),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 35,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                height: 0.1,
                              ),
                              children: [
                                TextSpan(
                                  text: 'and ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'FLOODING',
                                  style: TextStyle(color: Color(0xFF9AD1FF)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    _buildBeforeTyphoonPage(),
                    _buildDuringTyphoonPage(),
                    _buildAfterTyphoonPage(),
                  ],
                ),
              ),
               
              SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: const ScrollingDotsEffect(
                    activeDotColor: Color(0xFF0D1B4C),
                    dotColor: Colors.black26,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 6,
                    paintStyle: PaintingStyle.fill,
                  ),
                ),

                SizedBox(height: 50,)
            ],
            
          ),

          // 🔹 TRANSPARENT PAGE INDICATOR (no white bg)
          // Positioned(
          //   bottom: 25,
          //   left: 0,
          //   right: 0,
          //   child: IgnorePointer(
          //     child: Center(
          //       child: SmoothPageIndicator(
          //         controller: _pageController,
          //         count: 3,
          //         effect: const ScrollingDotsEffect(
          //           activeDotColor: Color(0xFF0D1B4C),
          //           dotColor: Colors.black26,
          //           dotHeight: 8,
          //           dotWidth: 8,
          //           spacing: 6,
          //           paintStyle: PaintingStyle.fill,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ), )
    );
  }

  // ===================================================
  // PAGE 1 — BEFORE A TYPHOON
  // ===================================================
  Widget _buildBeforeTyphoonPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSectionTitle('BEFORE A TYPHOON'),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Image.asset(
                      'assets/images/monitor.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'Monitor the news about weather disturbances. Watch for PAGASA bulletins every six hours.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Table(
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  width: 0.8,
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  _buildGridRow([
                    [
                      'assets/images/house.png',
                      'Check the strength of your house.',
                    ],
                    [
                      'assets/images/windows.png',
                      'Board up windows or use storm shutters.',
                    ],
                    ['assets/images/animals.png', 'Secure pets in safe areas.'],
                  ]),
                  _buildGridRow([
                    [
                      'assets/images/flash.png',
                      'Charge flashlights and radios. Keep candles and matches ready.',
                    ],
                    [
                      'assets/images/food.png',
                      'Store food and clean water supplies.',
                    ],
                    [
                      'assets/images/kit.png',
                      'Prepare an emergency grab bag with essentials.',
                    ],
                  ]),
                  _buildGridRow([
                    ['assets/images/docu.png', 'Secure important documents.'],
                    [
                      'assets/images/telep.png',
                      'List emergency hotline numbers.',
                    ],
                    [
                      'assets/images/evac.jpg',
                      'Plan possible evacuation routes.',
                    ],
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===================================================
  // PAGE 2 — DURING A TYPHOON
  // ===================================================
  Widget _buildDuringTyphoonPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('DURING A TYPHOON'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/monitor.png', width: 60, height: 60),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Continue to monitor the news for weather updates.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade400, thickness: 1),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Public storm signal number 1 or 2',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/signal.png', width: 120, height: 120),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'a. People travelling by sea and air must avoid unnecessary risks.\n'
                  'b. Evacuate from low-lying areas to higher grounds.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade400, thickness: 1),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'In case of storm signal number 3 or 4',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'a. Watch out for the passage of the "eye" of the storm.\n'
                  'b. Stay inside strong houses or evacuation centers.\n'
                  'c. Stay away from coasts and riverbanks.\n'
                  'd. Cancel all travels and outdoor activities.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Image.asset('assets/images/signal1.png', width: 130, height: 130),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade400, thickness: 1),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/cc.png', height: 85, width: 80),
              const SizedBox(width: 15),
              const Expanded(
                child: Text(
                  'If asked by authorities to evacuate, do so calmly. Turn off power, close windows, and secure your home.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================================
  // PAGE 3 — AFTER A TYPHOON
  // ===================================================
  Widget _buildAfterTyphoonPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSectionTitle('AFTER A TYPHOON'),
          const SizedBox(height: 25),
          Table(
            border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            children: [
              _buildGridRow([
                [
                  'assets/images/hand.png',
                  'Avoid touching live wires or wet outlets.',
                ],
                [
                  'assets/images/sak.png',
                  'Keep electrical appliances off until checked.',
                ],
                [
                  'assets/images/telepp.png',
                  'Call utility companies for damaged lines.',
                ],
              ]),
              _buildGridRow([
                [
                  'assets/images/drop.png',
                  'Boil water for at least 20 minutes before drinking.',
                ],
                [
                  'assets/images/snake.png',
                  'Watch out for snakes or stray animals.',
                ],
                [
                  'assets/images/cam.png',
                  'Take photos of damages for insurance claims.',
                ],
              ]),
              _buildGridRow([
                [
                  'assets/images/brush.png',
                  'Clean the house thoroughly after flooding.',
                ],
                [
                  'assets/images/house1.png',
                  'Return home only when declared safe.',
                ],
                [
                  'assets/images/house2.png',
                  'Check the stability of your house before entering.',
                ],
              ]),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================================
  // REUSABLE HELPERS
  // ===================================================
  static Widget _buildSectionTitle(String title) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        children: [
          const Text(
            'WHAT TO DO ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B4C),
              letterSpacing: 1,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(color: Color(0xFF0D1B4C)),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
                height: 0.9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static TableRow _buildGridRow(List<List<String>> tips) {
    return TableRow(
      children: tips.map((tip) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: buildMiniImageTip(tip[0], tip[1]),
        );
      }).toList(),
    );
  }

  static Widget buildMiniImageTip(String imagePath, String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(imagePath, width: 45, height: 45, fit: BoxFit.contain),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
