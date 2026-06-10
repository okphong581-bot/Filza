import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/aethera_theme.dart';
import 'aurastream_screen.dart';
import 'quantum_space_screen.dart';
import 'file_manager_screen.dart';
import 'home_screen.dart';

class AuraShell extends StatefulWidget {
  const AuraShell({super.key});

  @override
  State<AuraShell> createState() => _AuraShellState();
}

class _AuraShellState extends State<AuraShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const AuraStreamScreen(),
    const QuantumSpaceScreen(),
    const FileManagerScreen(),
    const HomeScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AetheraTheme.spaceBg,
      body: Stack(
        children: [
          // Screen pages
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // tab navigation only
            children: _screens,
          ),

          // Sliding Glass Bottom Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPadding > 0 ? bottomPadding : 16,
            child: Container(
              height: 64,
              decoration: AetheraTheme.glassDecoration(
                opacity: 0.12,
                borderOpacity: 0.18,
                radius: 20.0,
                glowOpacity: 0.05,
              ),
              child: Stack(
                children: [
                  // Sliding Glow Indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    left: (MediaQuery.of(context).size.width - 32) / 4 * _currentIndex + 8,
                    top: 8,
                    child: Container(
                      width: ((MediaQuery.of(context).size.width - 32) / 4) - 16,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AetheraTheme.neonPurple.withOpacity(0.25),
                            AetheraTheme.neonCyan.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AetheraTheme.neonPurple.withOpacity(0.4),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AetheraTheme.neonPurple.withOpacity(0.25),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                    ),
                  ),

                  // Navbar Tab Items
                  Row(
                    children: [
                      _buildNavItem(0, Icons.blur_circular_rounded, 'AuraStream'),
                      _buildNavItem(1, Icons.language_rounded, 'Quantum'),
                      _buildNavItem(2, Icons.folder_copy_rounded, 'Explorer'),
                      _buildNavItem(3, Icons.tune_rounded, 'Control'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final activeColor = index == 0
        ? AetheraTheme.neonPurple
        : index == 1
            ? AetheraTheme.neonCyan
            : index == 2
                ? AetheraTheme.neonMagenta
                : AetheraTheme.neonGreen;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.white38,
              size: 22,
            ).animate(target: isSelected ? 1.0 : 0.0)
             .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.15, 1.15), duration: 200.ms)
             .shimmer(duration: 1000.ms),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white30,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
