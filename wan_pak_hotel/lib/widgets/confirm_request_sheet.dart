import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConfirmRequestSheet extends StatelessWidget {
  const ConfirmRequestSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Confirm\nRequest',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 40,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Please review the details below.',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 32),
          
          // Details Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _buildDetailRow('Room', '304', isBold: true),
                const Divider(height: 32, color: Color(0xFFF0F0F0)),
                _buildDetailRow('Request Type', 'Housekeeping', isBold: true),
                const Divider(height: 32, color: Color(0xFFF0F0F0)),
                _buildDetailRow('Item', 'ผ้าเช็ดตัว'),
                const Divider(height: 32, color: Color(0xFFF0F0F0)),
                _buildDetailRow('Quantity', '2 ผืน'),
                const Divider(height: 32, color: Color(0xFFF0F0F0)),
                _buildDetailRow('Estimated Time', '10–15 นาที'),
                const Divider(height: 32, color: Color(0xFFF0F0F0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Assigned Team',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.cleaning_services_outlined,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Housekeeping',
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Info message
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const Text(
                  'Aura จะส่งคำขอนี้ไปยังมือถือของทีมแม่บ้านทันทีหลังยืนยัน',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request sent!')),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Confirm & Send Task'),
                  SizedBox(width: 8),
                  Icon(Icons.send_outlined, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textDark,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textLight,
            fontSize: 15,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
