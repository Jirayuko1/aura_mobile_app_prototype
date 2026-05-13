import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/task_skeleton.dart';
import 'staff_report_screen.dart';

class StaffTasksScreen extends StatefulWidget {
  const StaffTasksScreen({super.key});

  @override
  State<StaffTasksScreen> createState() => _StaffTasksScreenState();
}

class _StaffTasksScreenState extends State<StaffTasksScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _updateStatus(
    String ticketId,
    String newStatus, {
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'extracted_data.status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (photoUrl != null) {
        updateData['photo_proof'] = photoUrl;
      }

      if (newStatus == 'completed') {
        updateData['completed_by'] = _user?.uid;
      } else if (newStatus == 'in_progress') {
        updateData['assigned_to'] = _user?.uid;
      }

      await _firestore.collection('tickets').doc(ticketId).update(updateData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _updateNotes(String ticketId, String notes) async {
    await _firestore.collection('tickets').doc(ticketId).update({
      'internal_notes': notes,
    });
  }

  Future<void> _takePhotoAndComplete(String ticketId) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'proofs/$ticketId.jpg',
      );
      await storageRef.putFile(File(image.path));
      final url = await storageRef.getDownloadURL();

      await _updateStatus(ticketId, 'completed', photoUrl: url);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  bool _isUrgent(String? createdAtStr) {
    if (createdAtStr == null) return false;
    try {
      final createdAt = DateTime.parse(createdAtStr);
      return DateTime.now().difference(createdAt).inMinutes > 15;
    } catch (e) {
      return false;
    }
  }

  String _selectedCategory = 'ทั้งหมด';
  final List<Map<String, dynamic>> _categories = [
    {'label': 'ทั้งหมด', 'icon': Icons.grid_view_rounded, 'intent': 'all'},
    {'label': 'งานซ่อม', 'icon': Icons.build_rounded, 'intent': 'maintenance'},
    {'label': 'แม่บ้าน', 'icon': Icons.clean_hands_rounded, 'intent': 'housekeeping'},
    {'label': 'รูมเซอร์วิส', 'icon': Icons.room_service_rounded, 'intent': 'room_service'},
    {'label': 'อื่นๆ', 'icon': Icons.more_horiz_rounded, 'intent': 'other'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aura Staff',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tickets')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const TaskSkeleton();

          final allDocs = snapshot.data!.docs;
          
          // Filter logic
          final docs = allDocs.where((doc) {
            if (_selectedCategory == 'ทั้งหมด') return true;
            final data = doc.data() as Map<String, dynamic>;
            final intent = data['extracted_data']?['intent']?.toString().toLowerCase() ?? 'other';
            final selectedIntent = _categories.firstWhere((c) => c['label'] == _selectedCategory)['intent'];
            return intent == selectedIntent;
          }).toList();

          int myCompleted = 0;
          int newCount = 0;
          int inProgressCount = 0;

          for (var doc in allDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['extracted_data']?['status'] ?? 'pending';
            if (data['completed_by'] == _user?.uid &&
                (status == 'completed' || status == 'done'))
              myCompleted++;
            if (status == 'pending' || status == 'new') newCount++;
            if (status == 'in_progress') inProgressCount++;
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
            ),
            children: [
              // Staff Performance Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildPerformanceHeader(myCompleted),
              ),
              const SizedBox(height: 24),

              // Filter Bar (Edge-to-Edge scrolling with initial indent)
              _buildFilterBar(),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_selectedCategory ($inProgressCount)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'งานใหม่',
                            '$newCount',
                            Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'กำลังทำ',
                            '$inProgressCount',
                            Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'ของคุณ',
                            '$myCompleted',
                            Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Task List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    if (docs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text('ไม่มีงานค้าง'),
                        ),
                      ),
                    ...docs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final doc = entry.value;
                      final data = doc.data() as Map<String, dynamic>;
                      final extracted = data['extracted_data'] as Map<String, dynamic>?;
                      
                      // Robust Room Number Lookup
                      String room = '?';
                      if (data['room_number'] != null) {
                        room = data['room_number'].toString();
                      } else if (extracted != null) {
                        room = (extracted['room_number'] ?? 
                                extracted['roomNumber'] ?? 
                                extracted['room_no'] ?? 
                                extracted['room'] ?? '?').toString();
                      }
                      
                      final status = extracted?['status'] ?? data['status'] ?? 'pending';
                      final createdAt = data['created_at'];
                      final isUrgent = status == 'pending' && _isUrgent(createdAt);

                      return _StaggeredListItem(
                        key: ValueKey(doc.id),
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildEnhancedTaskCard(
                            docId: doc.id,
                            room: room,
                            title: extracted?['items'] ?? 'General Request',
                            notes: extracted?['notes'] ?? '',
                            internalNotes: data['internal_notes'] ?? '',
                            status: status,
                            isUrgent: isUrgent,
                            isDark: isDark,
                            fullData: data,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPerformanceHeader(int completed) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('staff')
          .where('name', isEqualTo: 'สมหญิง รักสะอาด') // In real app, match by _user?.email or UID
          .snapshots(),
      builder: (context, snapshot) {
        bool isOnDuty = false;
        String docId = '';
        
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final staffDoc = snapshot.data!.docs.first;
          docId = staffDoc.id;
          isOnDuty = (staffDoc.data() as Map<String, dynamic>)['status'] == 'checked-in';
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOnDuty 
                ? [AppTheme.primaryColor, AppTheme.accentColor]
                : [Colors.grey[700]!, Colors.grey[900]!],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isOnDuty ? AppTheme.primaryColor : Colors.black).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        child: Text(
                          _user?.email?[0].toUpperCase() ?? 'S',
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isOnDuty ? Colors.greenAccent : Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สวัสดี, พนักงาน Aura',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        Text(
                          isOnDuty ? 'สถานะ: กำลังเข้าเวร (On Duty)' : 'สถานะ: ออกเวรแล้ว (Off Duty)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ผลงานวันนี้: $completed งาน',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StaffReportScreen()),
                        ),
                        child: const Text(
                          'ดูรายงานละเอียด >',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        isOnDuty ? 'เข้าเวรอยู่' : 'อยู่นอกเวลา',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: isOnDuty,
                        onChanged: (val) {
                          if (docId.isNotEmpty) {
                            _firestore.collection('staff').doc(docId).update({
                              'status': val ? 'checked-in' : 'checked-out',
                            });
                          }
                        },
                        activeColor: Colors.greenAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }


  Widget _buildStatCard(String label, String val, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                val,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTaskCard({
    required String docId,
    required String room,
    required String title,
    required String notes,
    required String internalNotes,
    required String status,
    required bool isUrgent,
    required bool isDark,
    required Map<String, dynamic> fullData,
  }) {
    final bool isCompleted = status == 'completed' || status == 'done';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isCompleted)
            BoxShadow(
              color: (isUrgent ? Colors.redAccent : Colors.black).withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                ? Colors.white.withOpacity(0.05) 
                : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isUrgent 
                  ? Colors.redAccent.withOpacity(0.5) 
                  : Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: InkWell(
              onTap: () => _showTaskDetail(docId, fullData),
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUrgent)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      color: Colors.redAccent.withOpacity(0.8),
                      child: const Center(
                        child: Text(
                          '🚨 งานด่วน (URGENT)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ห้อง $room',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                            _buildBadge(status),
                          ],
                        ),
                        FutureBuilder<DocumentSnapshot>(
                          future: _firestore.collection('guests').doc(room).get(),
                          builder: (context, guestSnap) {
                            if (guestSnap.hasData && guestSnap.data!.exists) {
                              final guestData = guestSnap.data!.data() as Map<String, dynamic>;
                              return Text(
                                '👤 ${guestData['guest_name'] ?? 'ไม่ระบุชื่อ'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (notes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'โน้ต: $notes',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ),
                        const Divider(height: 32),
                        
                        Row(
                          children: [
                            const Icon(Icons.note_alt_outlined, size: 14, color: Colors.orange),
                            const SizedBox(width: 6),
                            const Text(
                              'บันทึกภายใน:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: isCompleted ? null : () => _showNotesDialog(docId, internalNotes),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.withOpacity(0.1)),
                            ),
                            child: Text(
                              internalNotes.isEmpty ? 'กดเพื่อเพิ่มบันทึก...' : internalNotes,
                              style: TextStyle(
                                color: internalNotes.isEmpty ? Colors.grey : (isDark ? Colors.white70 : Colors.black87),
                                fontSize: 13,
                                fontStyle: internalNotes.isEmpty ? FontStyle.italic : FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        if (!isCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: status == 'pending' || status == 'new'
                                ? ElevatedButton(
                                    onPressed: () => _updateStatus(docId, 'in_progress'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: const Text('รับงาน'),
                                  )
                                : ElevatedButton.icon(
                                    onPressed: () => _takePhotoAndComplete(docId),
                                    icon: const Icon(Icons.camera_alt, size: 18),
                                    label: const Text('ถ่ายรูปเพื่อปิดงาน'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildFilterBar() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['label'];
          
          return ChoiceChip(
            showCheckmark: false,
            avatar: Icon(
              cat['icon'],
              size: 18,
              color: isSelected ? Colors.white : AppTheme.primaryColor,
            ),
            label: Text(cat['label']),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedCategory = cat['label']);
              }
            },
            selectedColor: AppTheme.primaryColor.withOpacity(0.8),
            backgroundColor: Colors.white.withOpacity(0.1),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.2),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTaskDetail(String docId, Map<String, dynamic> data) {
    final extracted = data['extracted_data'] as Map<String, dynamic>?;
    final String room = extracted?['room_number']?.toString() ?? '?';
    final String status = extracted?['status'] ?? 'pending';
    final String? assignedTo = data['assigned_to'];
    final String? photoProof = data['photo_proof'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('รายละเอียดงาน',
                      style: Theme.of(context).textTheme.displayMedium),
                  _buildBadge(status),
                ],
              ),
              const SizedBox(height: 32),

              _buildSectionTitle(Icons.person, 'ข้อมูลลูกค้า (Guest)'),
              FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('guests').doc(room).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text('ไม่พบข้อมูลลูกค้าสำหรับห้องนี้');
                  }
                  final guest = snapshot.data!.data() as Map<String, dynamic>;
                  return Card(
                    elevation: 0,
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                              'ชื่อลูกค้า', guest['guest_name'] ?? '-'),
                          _buildDetailRow('หมายเลขห้อง', room),
                          _buildDetailRow('สถานะห้อง', guest['status'] ?? '-'),
                          _buildDetailRow(
                              'วันเช็คเอาท์', guest['check_out_date'] ?? '-'),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(Icons.assignment, 'รายละเอียดคำขอ'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.withOpacity(0.2))),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                          'รายการ', extracted?['items'] ?? 'General'),
                      _buildDetailRow('ประเภท (Intent)',
                          extracted?['intent'] ?? 'maintenance'),
                      const Divider(),
                      const Text('ข้อความจากลูกค้า:',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(extracted?['notes'] ?? 'ไม่มีข้อความเพิ่มเติม',
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (assignedTo != null) ...[
                _buildSectionTitle(Icons.engineering, 'พนักงานที่ดูแล'),
                FutureBuilder<QuerySnapshot>(
                  future: _firestore
                      .collection('staff')
                      .where('status', isEqualTo: 'checked-in')
                      .limit(1)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final staff = snapshot.data!.docs.first.data()
                          as Map<String, dynamic>;
                      return Card(
                        elevation: 0,
                        color: Colors.orange.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(staff['name'] ?? 'พนักงาน'),
                          subtitle: Text(
                              '${staff['role'] ?? '-'} • กะ: ${staff['shift'] ?? '-'}'),
                        ),
                      );
                    }
                    return const Text('กำลังดึงข้อมูลพนักงาน...');
                  },
                ),
                const SizedBox(height: 24),
              ],

              if (photoProof != null) ...[
                _buildSectionTitle(Icons.image, 'หลักฐานการทำงาน'),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    photoProof,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBadge(String status) {
    Color color = Colors.grey;
    String label = status;
    if (status == 'pending') {
      color = Colors.redAccent;
      label = 'NEW';
    }
    if (status == 'in_progress') {
      color = Colors.orange;
      label = 'DOING';
    }
    if (status == 'completed' || status == 'done') {
      color = Colors.green;
      label = 'DONE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showNotesDialog(String docId, String currentNotes) {
    final controller = TextEditingController(text: currentNotes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('บันทึกภายใน (Internal Notes)'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'พิมพ์รายละเอียดที่นี่...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateNotes(docId, controller.text);
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }
}

class _StaggeredListItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _StaggeredListItem({super.key, required this.index, required this.child});

  @override
  State<_StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<_StaggeredListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _offset = Tween<Offset>(begin: const Offset(0, 40), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _offset.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
