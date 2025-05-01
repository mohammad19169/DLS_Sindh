import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPendingAppointmentsScreen extends StatefulWidget {
  const AdminPendingAppointmentsScreen({super.key});

  @override
  State<AdminPendingAppointmentsScreen> createState() => _AdminPendingAppointmentsScreenState();
}

class _AdminPendingAppointmentsScreenState extends State<AdminPendingAppointmentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _updateAppointmentStatus(String docId, String status) async {
    try {
      await _firestore.collection('appointments').doc(docId).update({
        'status': status,
        'processedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment $status successfully'),
            backgroundColor: status == 'Approved' ? Colors.green.shade700 : Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Appointments'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name, CNIC or Token',
                labelStyle: TextStyle(color: theme.colorScheme.primary.withOpacity(0.8)),
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: theme.colorScheme.primary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              cursorColor: theme.colorScheme.primary,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('appointments')
                  .where('status', isEqualTo: 'Pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No pending appointments',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Process documents and sort by date in memory
                var docs = snapshot.data!.docs;
                docs.sort((a, b) {
                  var aDate = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
                  var bDate = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
                  return bDate.compareTo(aDate); // Newest first
                });

                // Filter based on search query
                var filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _searchQuery.isEmpty ||
                      data['fullName'].toString().toLowerCase().contains(_searchQuery) ||
                      data['cnic'].toString().toLowerCase().contains(_searchQuery) ||
                      data['token'].toString().toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matching appointments found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    var createdAt = (data['createdAt'] as Timestamp).toDate();
                    var appointmentDate = DateTime.parse(data['date']);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      color: theme.colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    data['fullName'],
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    data['token'],
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildDetailRow(context, 'CNIC', data['cnic']),
                            _buildDetailRow(context, 'Phone', data['phone']),
                            _buildDetailRow(context, 'Test Center', data['testCenter']),
                            _buildDetailRow(context, 'Date', DateFormat('MMMM dd, yyyy').format(appointmentDate)),
                            _buildDetailRow(context, 'Time Slot', data['timeSlot']),
                            _buildDetailRow(
                              context, 
                              'Requested On', 
                              DateFormat('MMMM dd, yyyy - hh:mm a').format(createdAt),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('APPROVE'),
                                    style: FilledButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.green.shade600,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => _updateAppointmentStatus(doc.id, 'Approved'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: Icon(Icons.close, size: 18, color: Colors.red.shade600),
                                    label: Text(
                                      'REJECT',
                                      style: TextStyle(color: Colors.red.shade600),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.red.shade600),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => _updateAppointmentStatus(doc.id, 'Rejected'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            ': ',
            style: theme.textTheme.bodyMedium,
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}