import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VoiceAssistantSheet extends StatelessWidget {
  const VoiceAssistantSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppTheme.bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    const Text(
                      'Aura',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Microphone
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 20,
                  blurRadius: 40,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  spreadRadius: 40,
                  blurRadius: 60,
                ),
              ],
            ),
            child: const Icon(
              Icons.mic_none,
              size: 40,
              color: AppTheme.textDark,
            ),
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Listening...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textDark,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Chat Flow
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildBotMessage('สวัสดีค่ะ ต้องการสั่งอาหารหรือขอของใช้ในห้องพักคะ?'),
                const SizedBox(height: 16),
                _buildUserMessage('ขอผ้าเช็ดตัวเพิ่ม 2 ผืน ห้อง 304'),
                const SizedBox(height: 16),
                _buildBotMessage('รับทราบค่ะ Aura จะส่งคำขอไปยังทีม Housekeeping ให้ทันที'),
              ],
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.bgColor,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.textDark,
                      elevation: 0,
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('ตรวจสอบคำขอก่อนส่ง'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textLight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: const Text('ยกเลิก'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.auto_awesome, size: 16, color: AppTheme.textDark),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textDark,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
