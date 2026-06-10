import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class InfoFirePage extends StatefulWidget {
  const InfoFirePage({super.key});

  @override
  State<InfoFirePage> createState() => _InfoFirePageState();
}

class _InfoFirePageState extends State<InfoFirePage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // ✅ allows transparent space under body
      backgroundColor: Colors.white,// ✅ fix white rectangle issue
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
        children: [
          // ✅ only content area is white
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // 🔥 HEADER SECTION
                Stack(
                  children: [
                    Image.asset(
                      'assets/images/fire.gif',
                      width: double.infinity,
                      height: 230,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: double.infinity,
                      height: 230,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF512F).withValues(alpha: 0.75),
                            const Color(0xFF8B0000).withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
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
                    const Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'FIRE',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color.fromARGB(255, 255, 190, 190),
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 🔹 SWIPEABLE CONTENT
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    children: [
                      _buildBeforeFirePage(),
                      _buildDuringFirePage(),
                      _buildAfterFirePage(),
                    ],
                  ),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: const ScrollingDotsEffect(
                    activeDotColor: Color(0xFFD32F2F),
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
          //           activeDotColor: Color(0xFFD32F2F),
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
      ),
        )
    );
  }

  // ===================================================
  // PAGE 1 — BEFORE A FIRE
  // ===================================================
  Widget _buildBeforeFirePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('BEFORE A FIRE'),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26, width: 0.8),
            ),
            child: Column(
              children: [
                _GridRow(
                  leftIcon: 'assets/images/map.png',
                  leftText: 'Create and practice fire escape plan.',
                  rightIcon: 'assets/images/route.png',
                  rightText: 'Make clear fire escape routes.',
                ),
                const Divider(height: 1, color: Colors.black26),
                _GridRow(
                  leftIcon: 'assets/images/fire_exit.png',
                  leftText: 'Build a fire exit.',
                  rightIcon: 'assets/images/alarm.png',
                  rightText:
                      'Check fire alarms and fire detection system regularly.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================
  // PAGE 2 — DURING A FIRE
  // ===================================================
  Widget _buildDuringFirePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('DURING A FIRE'),
          const SizedBox(height: 20),
          _TipRow(
            icon: 'assets/images/isolated.png',
            text:
                'Stay low, close to the ground while proceeding to the nearest fire exit.',
            customSize: 70,
          ),
          const Divider(thickness: 0.8),
          _TipRow(
            icon: 'assets/images/door.png',
            text:
                'Do not open the doors that are hot to touch.\nOpen the doors slowly.',
            iconRight: true,
          ),
          const Divider(thickness: 0.8),
          _TipRow(
            icon: 'assets/images/sdr.png',
            text:
                'If your cloth catches fire, remember – STOP, DROP, and ROLL.',
            customSize: 70,
          ),
          const Divider(thickness: 0.8),
          _TipRow(
            icon: 'assets/images/flashlight.png',
            text:
                'If you cannot escape, call for help using a torch light or a light coloured cloth from a window.',
            iconRight: true,
          ),
          const Divider(thickness: 0.8),
          _TipRow(icon: 'assets/images/call.png', text: 'Call AGAPAY app.'),
        ],
      ),
    );
  }

  // ===================================================
  // PAGE 3 — AFTER A FIRE
  // ===================================================
  Widget _buildAfterFirePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('AFTER A FIRE'),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26, width: 0.8),
            ),
            child: Column(
              children: [
                _GridRow(
                  leftIcon: 'assets/images/family.png',
                  leftText: 'Check for your family, colleagues and friends.',
                  rightIcon: 'assets/images/treated.png',
                  rightText:
                      'Be sure that all individuals who are injured are treated by a doctor.',
                ),
                const Divider(height: 1, color: Colors.black26),
                _GridRow(
                  leftIcon: 'assets/images/fire_home.png',
                  leftText:
                      'Avoid the fire area, unless it is declared safe to go near it.',
                  rightIcon: 'assets/images/trash.png',
                  rightText:
                      'Remove things that may cause additional harm, like broken glasses or shattered pieces of wood, etc.',
                ),
                const Divider(height: 1, color: Colors.black26),
                _GridRow(
                  leftIcon: 'assets/images/dept.png',
                  leftText:
                      'Ensure that the fire department inspects your home or the fire site.',
                  rightIcon: 'assets/images/msg.png',
                  rightText:
                      'If you have insured your house, contact your insurance company and save receipts related to the fire.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================
// REUSABLE COMPONENTS
// ===================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 35),
      child: Row(
        children: [
          const Text(
            'WHAT TO DO ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFFD32F2F),
              letterSpacing: 1,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(color: Color(0xFFD32F2F)),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  final String leftIcon;
  final String leftText;
  final String rightIcon;
  final String rightText;

  const _GridRow({
    required this.leftIcon,
    required this.leftText,
    required this.rightIcon,
    required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _GridBox(icon: leftIcon, text: leftText),
          ),
          const VerticalDivider(width: 1, color: Colors.black26),
          Expanded(
            child: _GridBox(icon: rightIcon, text: rightText),
          ),
        ],
      ),
    );
  }
}

class _GridBox extends StatelessWidget {
  final String icon;
  final String text;

  const _GridBox({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(icon, width: 40, height: 40),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String icon;
  final String text;
  final bool iconRight;
  final double customSize;

  const _TipRow({
    required this.icon,
    required this.text,
    this.iconRight = false,
    this.customSize = 45,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(icon, width: customSize, height: customSize);
    final textWidget = Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: iconRight ? [textWidget, image] : [image, textWidget],
      ),
    );
  }
}
