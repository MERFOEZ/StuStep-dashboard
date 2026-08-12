import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/group_model.dart';
import '../../models/message_model.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Local state for mock groups
  final List<GroupModel> _mockGroups = [
    GroupModel(
      groupId: 'g1',
      name: 'Advanced Calculus Study',
      description:
          'Group for students studying advanced integration and multivariable calculus.',
      createdBy: 'Dr. Sarah Jenkins',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      members: ['u1', 'u4', 'u6'],
      lastMessage: 'Let\'s review question 4 on page 120.',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      academicYear: '2026/2027',
    ),
    GroupModel(
      groupId: 'g2',
      name: 'Computer Science Thesis',
      description: 'Senior project coordination chat.',
      createdBy: 'Eng. Ahmad Qasim',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      members: ['u2', 'u5', 'u7'],
      lastMessage: 'Please upload your git repositories by tonight.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      academicYear: '2026/2027',
    ),
    GroupModel(
      groupId: 'g3',
      name: 'Physics Lab 3 - Team B',
      description: 'Coordination for electromagnetism experiments.',
      createdBy: 'Fatima Al-Sayed',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      members: ['u4', 'u6', 'u7'],
      lastMessage: 'The lab report draft is in our shared drive.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 12)),
      academicYear: '2026/2027',
    ),
    GroupModel(
      groupId: 'g4',
      name: 'University Freshmen Lounge',
      description: 'Social space for incoming first-year academic discussions.',
      createdBy: 'Omar Farooq',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      members: ['u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7'],
      lastMessage: 'Welcome to all the new students joining us today!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      academicYear: '2026/2027',
    ),
  ];

  // Mock messages for monitoring
  final Map<String, List<MessageModel>> _mockMessages = {
    'g1': [
      MessageModel(
        messageId: 'm1',
        senderId: 'u4',
        senderName: 'Fatima Al-Sayed',
        content: 'Did anyone solve the homework?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        type: 'text',
      ),
      MessageModel(
        messageId: 'm2',
        senderId: 'u6',
        senderName: 'Ali Reda',
        content: 'Yes, I got 42.5 for the integral.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        type: 'text',
      ),
      MessageModel(
        messageId: 'm3',
        senderId: 'u1',
        senderName: 'Dr. Sarah Jenkins',
        content:
            'Make sure you write down the intermediate steps. I want to see the integration by parts.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        type: 'text',
      ),
      MessageModel(
        messageId: 'm4',
        senderId: 'u4',
        senderName: 'Fatima Al-Sayed',
        content: 'Let\'s review question 4 on page 120.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: 'text',
      ),
    ],
    'g2': [
      MessageModel(
        messageId: 'm5',
        senderId: 'u7',
        senderName: 'Lina Khalfan',
        content: 'Is the server running?',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: 'text',
      ),
      MessageModel(
        messageId: 'm6',
        senderId: 'u2',
        senderName: 'Eng. Ahmad Qasim',
        content: 'Yes, but pull the latest main branch first.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        type: 'text',
      ),
      MessageModel(
        messageId: 'm7',
        senderId: 'u7',
        senderName: 'Lina Khalfan',
        content: 'Please upload your git repositories by tonight.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: 'text',
      ),
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMonitorDialog(GroupModel group, String Function(String, String) t) {
    showDialog(
      context: context,
      builder: (context) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white10),
          ),
          title: Row(
            children: [
              const Icon(Icons.monitor_heart_rounded, color: Color(0xFF2DD4BF)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      t(
                        'Room Moderation Feed (Live Peeking)',
                        'بث مراقبة الغرفة (مراقبة مباشرة)',
                      ),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 550,
            height: 400,
            child: authProvider.useMock
                ? _buildMessageFeed(_mockMessages[group.groupId] ?? [], t)
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('groups')
                        .doc(group.groupId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(30)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading messages: ${snapshot.error}',
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs
                          .map((doc) {
                            return MessageModel.fromMap(
                              doc.data() as Map<String, dynamic>,
                              doc.id,
                            );
                          })
                          .toList()
                          .reversed
                          .toList(); // Reverse to read chronologically

                      return _buildMessageFeed(messages, t);
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                t('Close Feed', 'إغلاق البث'),
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageFeed(
    List<MessageModel> messages,
    String Function(String, String) t,
  ) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          t(
            'No recent messages found in this room.',
            'لا توجد رسائل حديثة في هذه الغرفة.',
          ),
          style: const TextStyle(color: Colors.white30),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final timestampStr = msg.timestamp != null
              ? '${msg.timestamp!.hour.toString().padLeft(2, '0')}:${msg.timestamp!.minute.toString().padLeft(2, '0')}'
              : '--:--';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      msg.senderName,
                      style: const TextStyle(
                        color: Color(0xFF2DD4BF),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timestampStr,
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  msg.content,
                  style: const TextStyle(
                    color: Color(0xDEFFFFFF),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteGroupDialog(
    GroupModel group,
    String Function(String, String) t,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            t('Delete Room?', 'حذف الغرفة؟'),
            style: const TextStyle(color: Colors.redAccent),
          ),
          content: Text(
            t(
              'Are you sure you want to permanently delete the chat room "${group.name}"?\nAll group messages will be deleted.',
              'هل أنت متأكد من حذف غرفة الدردشة "${group.name}" نهائياً؟\nسيتم حذف جميع رسائل المجموعة.',
            ),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                t('Cancel', 'إلغاء'),
                style: const TextStyle(color: Colors.white38),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                if (authProvider.useMock) {
                  setState(() {
                    _mockGroups.removeWhere((g) => g.groupId == group.groupId);
                  });
                } else {
                  FirebaseFirestore.instance
                      .collection('groups')
                      .doc(group.groupId)
                      .delete();
                  FirebaseFirestore.instance.collection('activity_logs').add({
                    'action': 'group_deleted',
                    'actorName': authProvider.currentUser?.name ?? 'Admin',
                    'targetName': group.name,
                    'details': '',
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      t(
                        'Room "${group.name}" deleted.',
                        'تم حذف الغرفة "${group.name}".',
                      ),
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: Text(
                t('Delete', 'حذف'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  List<GroupModel> _filterGroups(List<GroupModel> groups) {
    return groups.where((group) {
      return group.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (group.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final accentColor = const Color(0xFF2DD4BF);
    final cardColor = const Color(0xFF1E293B);

    String t(String en, String ar) => authProvider.isArabic ? ar : en;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: t(
                        'Search groups by name or description...',
                        'بحث المجموعات بالاسم أو الوصف...',
                      ),
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white54,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.03),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: accentColor.withOpacity(0.4),
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Group list container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              clipBehavior: Clip.antiAlias,
              child: authProvider.useMock
                  ? _buildGroupGrid(_filterGroups(_mockGroups), t)
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('groups')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final groups = snapshot.data!.docs.map((doc) {
                          return GroupModel.fromMap(
                            doc.data() as Map<String, dynamic>,
                            doc.id,
                          );
                        }).toList();

                        return _buildGroupGrid(_filterGroups(groups), t);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupGrid(
    List<GroupModel> groups,
    String Function(String, String) t,
  ) {
    if (groups.isEmpty) {
      return Center(
        child: Text(
          t('No academic groups found.', 'لم يتم العثور على مجموعات أكاديمية.'),
          style: const TextStyle(color: Colors.white30, fontSize: 16),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final isMedium =
            constraints.maxWidth > 550 && constraints.maxWidth <= 900;

        int crossAxisCount = 1;
        if (isWide) {
          crossAxisCount = 3;
        } else if (isMedium) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final grp = groups[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          grp.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DD4BF).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t(
                            '${grp.members.length} members',
                            '${grp.members.length} أعضاء',
                          ),
                          style: const TextStyle(
                            color: Color(0xFF2DD4BF),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    grp.description ??
                        t('No description provided.', 'لا يوجد وصف.'),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  const Divider(color: Colors.white10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t(
                          'Year: ${grp.academicYear ?? 'General'}',
                          'السنة: ${grp.academicYear ?? 'عام'}',
                        ),
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 11,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.monitor_heart_rounded,
                              size: 20,
                            ),
                            color: const Color(0xFF2DD4BF),
                            tooltip: t(
                              'Live Monitor Feed',
                              'بث المراقبة المباشر',
                            ),
                            onPressed: () => _showMonitorDialog(grp, t),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                            color: Colors.redAccent,
                            tooltip: t('Delete Group', 'حذف المجموعة'),
                            onPressed: () => _showDeleteGroupDialog(grp, t),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
