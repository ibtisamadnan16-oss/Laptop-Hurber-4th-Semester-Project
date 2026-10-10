import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/firebase_collections.dart';
import '../../models/support_ticket_model.dart';
import '../../utils/app_colors.dart';

class ManageFeedbackScreen extends StatefulWidget {
  const ManageFeedbackScreen({super.key});

  @override
  State<ManageFeedbackScreen> createState() => _ManageFeedbackScreenState();
}

class _ManageFeedbackScreenState extends State<ManageFeedbackScreen> {
  String _selectedCategory = 'All';
  Stream<QuerySnapshot<Map<String, dynamic>>>? _ticketStream;

  @override
  void initState() {
    super.initState();
    try {
      _ticketStream = FirebaseFirestore.instance
          .collection(Fc.supportTickets)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (_) {
      _ticketStream = null;
    }
  }

  final List<SupportTicketModel> _demoTickets = [
    SupportTicketModel(
      id: 'TICK-101',
      name: 'Usman Ali',
      email: 'usman.ali@gmail.com',
      category: 'Order Issue',
      subject: 'Order #1002 delay inquiry',
      message:
          'When will my HP EliteBook 840 be dispatched? I need it for urgent university exams.',
      status: 'Open',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SupportTicketModel(
      id: 'TICK-102',
      name: 'Ayesha Siddiqua',
      email: 'ayesha.s@outlook.com',
      category: 'Payment Issue',
      subject: 'JazzCash payment confirmation',
      message:
          'I paid via JazzCash for my MacBook Air. Please confirm if transaction went through.',
      status: 'In Progress',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    SupportTicketModel(
      id: 'TICK-103',
      name: 'Bilal Tariq',
      email: 'bilal.t@yahoo.com',
      category: 'Delivery Issue',
      subject: 'Change delivery address',
      message:
          'Can I change my delivery address to office address in Gulberg Lahore?',
      status: 'Resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<void> _updateTicketStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection(Fc.supportTickets)
          .doc(docId)
          .update({'status': newStatus});
    } catch (_) {
      setState(() {
        final idx = _demoTickets.indexWhere((t) => t.id == docId);
        if (idx != -1) {
          _demoTickets[idx] = SupportTicketModel(
            id: _demoTickets[idx].id,
            name: _demoTickets[idx].name,
            email: _demoTickets[idx].email,
            category: _demoTickets[idx].category,
            subject: _demoTickets[idx].subject,
            message: _demoTickets[idx].message,
            status: newStatus,
            createdAt: _demoTickets[idx].createdAt,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Customer Feedback & Tickets',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _ticketStream,
        builder: (context, snapshot) {
          List<SupportTicketModel> tickets = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            tickets = snapshot.data!.docs
                .map((d) => SupportTicketModel.fromMap(d.data(), d.id))
                .toList();
          } else {
            tickets = _demoTickets;
          }

          final filteredTickets = tickets.where((t) {
            if (_selectedCategory == 'All') return true;
            return t.category.toLowerCase() == _selectedCategory.toLowerCase();
          }).toList();

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children:
                      ['All', ...SupportTicketModel.categories].map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isSel ? Colors.white : AppColors.textSecondary,
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: filteredTickets.isEmpty
                    ? const Center(
                        child: Text(
                          'No feedback tickets found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredTickets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, index) {
                          final ticket = filteredTickets[index];
                          final statusColor = _getStatusColor(ticket.status);

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        ticket.category,
                                        style: const TextStyle(
                                          color: AppColors.primaryLight,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      color: AppColors.surface,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                              alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: statusColor.withValues(
                                                  alpha: 0.4)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              ticket.status,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(Icons.arrow_drop_down,
                                                color: statusColor, size: 16),
                                          ],
                                        ),
                                      ),
                                      onSelected: (newVal) =>
                                          _updateTicketStatus(
                                              ticket.id, newVal),
                                      itemBuilder: (popCtx) => [
                                        const PopupMenuItem(
                                            value: 'Open',
                                            child: Text('Open',
                                                style: TextStyle(
                                                    color: AppColors.warning))),
                                        const PopupMenuItem(
                                            value: 'In Progress',
                                            child: Text('In Progress',
                                                style: TextStyle(
                                                    color: AppColors.accent))),
                                        const PopupMenuItem(
                                            value: 'Resolved',
                                            child: Text('Resolved',
                                                style: TextStyle(
                                                    color: AppColors.success))),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  ticket.subject,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ticket.message,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'From: ${ticket.name} (${ticket.email})',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return AppColors.success;
      case 'in progress':
      case 'in-progress':
        return AppColors.accent;
      case 'open':
      default:
        return AppColors.warning;
    }
  }
}
