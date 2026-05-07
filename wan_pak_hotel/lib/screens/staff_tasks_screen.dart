import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../theme/app_theme.dart';

class StaffTasksScreen extends StatefulWidget {
  const StaffTasksScreen({super.key});

  @override
  State<StaffTasksScreen> createState() => _StaffTasksScreenState();
}

class _StaffTasksScreenState extends State<StaffTasksScreen> {
  int _currentIndex = 0;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WAN-PAK HOTEL',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Staff Tasks',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 48,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Stats Row
              Row(
                children: [
                  Expanded(child: _buildStatCard('New', '8', const Color(0xFFFFEAEA))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('In\nProgress', '4', const Color(0xFFFFF4D9))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Done', '21', const Color(0xFFF0F0F0))),
                ],
              ),
              const SizedBox(height: 32),
              
              // Task List
              _buildTaskCard(
                room: '304',
                department: 'Housekeeping',
                detail: 'ผ้าเช็ดตัว 2 ผืน',
                status: 'New',
                statusColor: const Color(0xFFE57373),
                actionText: 'Accept Task',
                actionIcon: Icons.check_circle_outline,
                isPrimaryAction: true,
              ),
              const SizedBox(height: 16),
              _buildTaskCard(
                room: '502',
                department: 'Room Service',
                detail: 'ข้าวผัด + น้ำเปล่า',
                status: 'In Progress',
                statusColor: const Color(0xFFF6C23E),
                actionText: 'Mark Completed',
                actionIcon: Icons.check,
                isPrimaryAction: false,
              ),
              const SizedBox(height: 16),
              _buildTaskCard(
                room: '218',
                department: 'Housekeeping',
                detail: 'หมอนเพิ่ม 1 ใบ',
                status: 'New',
                statusColor: const Color(0xFFE57373),
                actionText: 'Accept Task',
                actionIcon: Icons.check_circle_outline,
                isPrimaryAction: true,
              ),
              const SizedBox(height: 16),
              _buildCompletedTaskCard(
                room: '710',
                department: 'Room Service',
                detail: 'Late night snack',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
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

  Widget _buildStatCard(String title, String count, Color indicatorColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 24,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(bottom: 8),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 36,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard({
    required String room,
    required String department,
    required String detail,
    required String status,
    required Color statusColor,
    required String actionText,
    required IconData actionIcon,
    required bool isPrimaryAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room $room',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == 'New' ? Icons.new_releases_outlined : Icons.hourglass_bottom,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            department,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: isPrimaryAction
                ? ElevatedButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(actionIcon, size: 18),
                        const SizedBox(width: 8),
                        Text(actionText),
                      ],
                    ),
                  )
                : OutlinedButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(actionIcon, size: 18),
                        const SizedBox(width: 8),
                        Text(actionText),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTaskCard({
    required String room,
    required String department,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room $room',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight, // Greyed out
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            department,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textLight, // Greyed out
            ),
          ),
        ],
      ),
    );
  }
}
