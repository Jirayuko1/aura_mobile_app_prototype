import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import '../widgets/voice_assistant_sheet.dart';
import '../widgets/confirm_request_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onShowVoiceAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceAssistantSheet(),
    );
  }

  void _onShowConfirmRequest() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ConfirmRequestSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: Text(
          'Aura',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 28,
                color: Colors.black,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140), // Space for sticky FAB
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Aura Logo Placeholder
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.room_service_outlined,
                          size: 32,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aura',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontSize: 14,
                                color: AppTheme.textDark,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Greeting Text
                  Text(
                    'สวัสดีค่ะ\nวันนี้ให้ Aura\nช่วยดูแลอะไรคะ?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 34,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 32),
                  // Quick Actions
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildQuickActionChip('ขอผ้าเช็ดตัวเพิ่ม'),
                      _buildQuickActionChip('ขอหมอนเพิ่ม'),
                      _buildQuickActionChip('สั่งอาหาร'),
                      _buildQuickActionChip('ขอช้อนส้อม'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Category Cards
                  _buildCategoryCard(
                    icon: Icons.room_service_outlined,
                    title: 'Room Service',
                    description: 'Order food & beverages directly to your room.',
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Housekeeping',
                    description: 'Request extra towels, pillows, or room makeup.',
                    onTap: _onShowConfirmRequest, // For demo purposes
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    icon: Icons.spa_outlined,
                    title: 'Amenities',
                    description: 'Pool, Gym, Spa reservations.',
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    icon: Icons.help_outline,
                    title: 'Ask Hotel FAQ',
                    description: 'WiFi, check-out time,...',
                  ),
                ],
              ),
            ),
          ),
          
          // Sticky Bottom Actions
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 64,
                  width: 64,
                  child: FloatingActionButton(
                    onPressed: _onShowVoiceAssistant,
                    backgroundColor: AppTheme.primaryColor,
                    elevation: 6,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.mic,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Talk to Aura',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildQuickActionChip(String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.white,
      labelStyle: const TextStyle(
        color: AppTheme.textDark,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      side: BorderSide(color: Colors.grey.shade300, width: 1.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: _onShowConfirmRequest,
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFDF7E7), // Light gold/beige background
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF9E7C30), // Dark gold icon
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
