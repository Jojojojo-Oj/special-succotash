import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class InfoEarthquakePage extends StatefulWidget {
  const InfoEarthquakePage({super.key});

  @override
  State<InfoEarthquakePage> createState() => _InfoEarthquakePageState();
}

class _InfoEarthquakePageState extends State<InfoEarthquakePage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
       // ✅ allows content to go under safe area     
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
        children: [
          // 🔹 White background only for content
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // 🔹 HEADER SECTION
                Stack(
                  children: [
                    Image.asset(
                      'assets/images/earthquake.gif',
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
                            const Color(0xFFA85F27).withValues(alpha: 0.8),
                            const Color(0xFF593700).withValues(alpha: 0.8),
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
                          'EARTHQUAKE',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFFFFE8C2),
                            fontSize: 40,
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
                      _buildBeforePage(),
                      _buildDuringPage(),
                      _buildAfterPage(),
                    ],
                  ),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: const ScrollingDotsEffect(
                    activeDotColor: Color(0xFF593700),
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

          // ✅ TRANSPARENT PAGE INDICATOR (no white background)
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
          //           activeDotColor: Color(0xFF593700),
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
  // PAGE 1 — BEFORE AN EARTHQUAKE
  // ===================================================
  Widget _buildBeforePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionTitle('BEFORE AN EARTHQUAKE'),
          SizedBox(height: 25),
          _BeforeTipRow(
            'assets/images/hazard.png',
            'KNOW THE HAZARDS.',
            'Familiarize yourself with earthquake hazards in your area.',
          ),
          Divider(thickness: 0.8),
          _BeforeTipRow(
            'assets/images/street.png',
            'KNOW THE EVACUATION AREA.',
            'Check the nearest route going to identified evacuation area.',
            alignRight: true,
          ),
          Divider(thickness: 0.8),
          _BeforeTipRow(
            'assets/images/backpack.png',
            'PREPARE AN EMERGENCY SUPPLY KIT.',
            'Make it accessible at all times.',
          ),
          Divider(thickness: 0.8),
          _BeforeTipRow(
            'assets/images/home.png',
            'PREPARE YOUR HOUSE OR WORKPLACE.',
            'Secure heavy furniture, check for potential hazards, and create an emergency plan.',
            alignRight: true,
          ),
          Divider(thickness: 0.8),
          _BeforeTipRow(
            'assets/images/extinguisher.png',
            'LEARN TO USE.',
            'First aid kit, fire extinguisher, alarms, switching off waterlines, gas tanks, and circuit breaker.',
          ),
          Divider(thickness: 0.8),
          _BeforeTipRow(
            'assets/images/practice.png',
            'PARTICIPATE DURING DRILLS.',
            'Regularly practice the evacuation procedure.',
            alignRight: true,
          ),
        ],
      ),
    );
  }

  // ===================================================
  // PAGE 2 — DURING AN EARTHQUAKE
  // ===================================================
  Widget _buildDuringPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('DURING AN EARTHQUAKE'),
          const SizedBox(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: _IconTipAligned(
                  image: 'assets/images/drop1.png',
                  description: 'Drop on the floor\non your hands and knees.',
                ),
              ),
              Expanded(
                child: _IconTipAligned(
                  image: 'assets/images/cover.png',
                  description: 'Take cover your\nhead and neck.',
                ),
              ),
              Expanded(
                child: _IconTipAligned(
                  image: 'assets/images/hold.png',
                  description:
                      'Hold on to your shelter\nuntil the shaking stops.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Divider(thickness: 0.8),
          const _DuringTipRow(
            'assets/images/palm.png',
            'STAY CALM and ALERT',
            'Watch out for falling objects, glass, and shelves that may cause injury.',
          ),
          const Divider(thickness: 0.8),
          Row(
            children: const [
              Expanded(
                child: _DuringTipRow(
                  'assets/images/open_area.png',
                  'IF OUTSIDE,',
                  'move to an open area.',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _DuringTipRow(
                  'assets/images/book.png',
                  '',
                  'Bring something to cover and protect your head.',
                ),
              ),
            ],
          ),
          const Divider(thickness: 0.8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Do not go back to the buildings until it is announced safe to do so.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Image.asset('assets/images/building.png', width: 45, height: 45),
            ],
          ),
          const Divider(thickness: 0.8),
          const _DuringTipRow(
            'assets/images/stop.png',
            'STOP IF INSIDE IN MOVING VEHICLE',
            'Do not cross bridges, overpasses, or flyovers.',
          ),
        ],
      ),
    );
  }

  // ===================================================
  // PAGE 3 — AFTER AN EARTHQUAKE
  // ===================================================
  Widget _buildAfterPage() {
    final tips = [
      [
        'assets/images/exit.png',
        'EVACUATE',
        'As soon as the shaking stops, take the fastest and safest way out.',
        true,
      ],
      [
        'assets/images/bandage.png',
        'Check yourself and others for injuries.',
        '',
        false,
      ],
      ['assets/images/shock.png', 'Expect aftershocks', '', false],
      [
        'assets/images/radio.png',
        'BE UPDATED',
        'Monitor the situation from the radio.',
        true,
      ],
      ['assets/images/med.png', 'Get medical care if necessary.', '', false],
      ['assets/images/surround.png', 'Inspect your surroundings', '', false],
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('AFTER AN EARTHQUAKE'),
          const SizedBox(height: 25),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
            ),
            child: Column(
              children: [
                _GridRow(left: tips[0], right: tips[1]),
                const Divider(height: 1, color: Colors.black26),
                _GridRow(left: tips[2], right: tips[3]),
                const Divider(height: 1, color: Colors.black26),
                _GridRow(left: tips[4], right: tips[5]),
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
      padding: const EdgeInsets.only(left: 7),
      child: Row(
        children: [
          const Text(
            'WHAT TO DO ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            color: const Color(0xFF593700),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ all your reusable widgets (BeforeTipRow, DuringTipRow, IconTipAligned, GridRow, GridBox)
class _BeforeTipRow extends StatelessWidget {
  final String imagePath, title, desc;
  final bool alignRight;
  const _BeforeTipRow(
    this.imagePath,
    this.title,
    this.desc, {
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(imagePath, width: 45, height: 45);
    final text = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: alignRight
            ? [text, const SizedBox(width: 20), image]
            : [image, const SizedBox(width: 20), text],
      ),
    );
  }
}

class _DuringTipRow extends StatelessWidget {
  final String imagePath, title, desc;
  const _DuringTipRow(this.imagePath, this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, width: 40, height: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTipAligned extends StatelessWidget {
  final String image;
  final String description;
  const _IconTipAligned({required this.image, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(image, width: 90, height: 90, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  final List left, right;
  const _GridRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _GridBox(left[0], left[1], left[2], isBold: left[3])),
          const VerticalDivider(width: 1, color: Colors.black26),
          Expanded(
            child: _GridBox(right[0], right[1], right[2], isBold: right[3]),
          ),
        ],
      ),
    );
  }
}

class _GridBox extends StatelessWidget {
  final String image, title, desc;
  final bool isBold;
  const _GridBox(this.image, this.title, this.desc, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, width: 45, height: 45),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          if (desc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
