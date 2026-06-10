import 'package:flutter/material.dart';

class SegmentedHome extends StatefulWidget {
  const SegmentedHome({super.key});

  @override
  State<SegmentedHome> createState() => _SegmentedHomeState();
}

class _SegmentedHomeState extends State<SegmentedHome> {
  String _selected = 'News';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          
          AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 10,
          ),
          Padding(
            padding: EdgeInsets.only( bottom: 10),
            child: SegmentedButton<String>(         
                segments: const [
                  ButtonSegment(value: 'Today', label: Text('Today', style: TextStyle(),)),
                  ButtonSegment(value: 'News', label: Text('News')),
                  ButtonSegment(value: 'Announcement', label: Text('Announcement')),
                  ButtonSegment(value: 'Community', label: Text('Community')),
                ],
                selected: {_selected},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _selected = newSelection.first);
                },
                showSelectedIcon: false,
              ),
          ),

          // Expanded(
          //   child: AnimatedSwitcher(
          //     duration: const Duration(milliseconds: 300),
          //     child: _getContainer(_selected),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Widget _getContainer(String selected) {
  //   switch (selected) {
  //     case 'Today':
  //       return const RedContainer(key: ValueKey('red'));
  //     case 'News':
  //       return const GreenContainer(key: ValueKey('green'));
  //     case 'Announcement':
  //       return const BlueContainer(key: ValueKey('blue'));
  //     case 'Community':
  //       return const BlueContainer();
  //     default:
  //       return const SizedBox.shrink();
  //   }
  // }
}
