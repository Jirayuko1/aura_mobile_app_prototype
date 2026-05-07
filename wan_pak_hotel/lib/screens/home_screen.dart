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
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Aura Logo Placeholder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.room_service,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              // Greeting Text
              Text(
                'สวัสดีค่ะ\nวันนี้ให้ Aura\nช่วยดูแลอะไรคะ?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 32,
                      height: 1.2,
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
              const SizedBox(height: 100), // padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 72,
        width: 72,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: _onShowVoiceAssistant,
          backgroundColor: AppTheme.primaryColor,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.mic,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
      ),
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: _onShowConfirmRequest, // For demo purposes
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
              color: Colors.black.withOpacity(0.02),
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
                color: AppTheme.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
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
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
