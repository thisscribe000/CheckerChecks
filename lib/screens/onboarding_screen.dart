import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/stitch_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0; // 0: Welcome, 1: Role Selection
  String _selectedRole = 'Photography';

  final List<Map<String, dynamic>> _roles = [
    {'name': 'Photography', 'icon': Icons.photo_camera_outlined},
    {'name': 'Video', 'icon': Icons.videocam_outlined},
    {'name': 'Audio', 'icon': Icons.mic_none_outlined},
    {'name': 'Events', 'icon': Icons.event_outlined},
    {'name': 'Tech', 'icon': Icons.construction_outlined},
    {'name': 'Other', 'icon': Icons.work_outline},
  ];

  void _onFinish() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.completeOnboarding(_selectedRole);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: _step == 0 ? _buildWelcomeStep() : _buildRoleStep(),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: StitchTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: StitchTheme.outlineVariant),
              ),
              child: Text(
                'CHECKERCHECKS',
                style: StitchTheme.labelCaps(context).copyWith(color: StitchTheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Prepare your gig.\nPack with confidence.',
              style: StitchTheme.display(context).copyWith(height: 1.2),
            ),
            const SizedBox(height: 16),
            Text(
              'Never arrive at a venue missing a cable, battery, or camera body again.',
              style: StitchTheme.bodyLg(context),
            ),
          ],
        ),

        // Bottom CTA Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _step = 1;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchTheme.primary,
              foregroundColor: StitchTheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Get Started',
              style: StitchTheme.headlineMd(context).copyWith(
                color: StitchTheme.onPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What type of work do you do?',
          style: StitchTheme.headlineLg(context),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us suggest relevant equipment for your gigs.',
          style: StitchTheme.bodyLg(context),
        ),
        const SizedBox(height: 32),

        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: _roles.length,
            itemBuilder: (context, index) {
              final role = _roles[index];
              final isSelected = _selectedRole == role['name'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = role['name'];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: isSelected
                      ? StitchTheme.cardDecorationActive
                      : StitchTheme.cardDecoration,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        role['icon'] as IconData,
                        size: 28,
                        color: isSelected ? StitchTheme.primary : StitchTheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        role['name'] as String,
                        style: StitchTheme.headlineMd(context).copyWith(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _onFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: StitchTheme.primary,
              foregroundColor: StitchTheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Continue to App',
              style: StitchTheme.headlineMd(context).copyWith(
                color: StitchTheme.onPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
