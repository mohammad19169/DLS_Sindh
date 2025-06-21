import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminRenewalsScreen extends StatefulWidget {
  const AdminRenewalsScreen({super.key});

  @override
  State<AdminRenewalsScreen> createState() => _AdminRenewalsScreenState();
}

class _AdminRenewalsScreenState extends State<AdminRenewalsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Pending';
  String _sortOption = 'Newest First';

  final List<String> _statusOptions = ['Pending', 'Approved', 'Dispatched', 'Rejected'];
  final List<String> _sortOptions = [
    'Newest First',
    'Oldest First',
    'License Number',
    'Name A-Z'
  ];

  Future<void> _updateRenewalStatus(String docId, String newStatus) async {
    try {
      final renewalsRef = _firestore.collection('license_renewals').doc(docId);
      final renewalDoc = await renewalsRef.get();
      
      if (!renewalDoc.exists) {
        throw Exception('Renewal document not found');
      }

      final renewalData = renewalDoc.data() as Map<String, dynamic>;
      final licenseId = renewalData['licenseId'] as String?;
      final requestedExpiryDate = renewalData['requestedExpiryDate'] as String?;

      // Start a batch write to update all documents atomically
      final batch = _firestore.batch();
      
      // 1. Update the renewal status in license_renewals collection
      batch.update(renewalsRef, {
        'status': newStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // 2. If status is Dispatched, update the main license document
      if (newStatus == 'Dispatched' && licenseId != null) {
        final licenseRef = _firestore.collection('licenses').doc(licenseId);
        
        // Prepare updates for the license document
        final licenseUpdates = {
          'status': 'Active',
          'expiryDate': requestedExpiryDate,
          'lastUpdated': FieldValue.serverTimestamp(),
        };
        
        // Update the nested renewalRequest map
        final renewalRequestUpdates = {
          'status': newStatus,
          'lastUpdated': FieldValue.serverTimestamp(),
        };
        
        // Update both the main document and nested renewalRequest
        batch.update(licenseRef, {
          ...licenseUpdates,
          'renewalRequest': renewalRequestUpdates,
        });
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to $newStatus'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('License Renewals'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filters and Search Section
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter & Search',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status Filter Chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _statusOptions.map((status) {
                        final isSelected = _selectedStatus == status;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedStatus = status;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? _getStatusColor(status) : colorScheme.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, license number or CNIC',
                      prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Sort Dropdown
                  DropdownButtonFormField<String>(
                    value: _sortOption,
                    decoration: InputDecoration(
                      labelText: 'Sort by',
                      labelStyle: TextStyle(color: colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                    dropdownColor: colorScheme.surface,
                    items: _sortOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _sortOption = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Renewals List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('license_renewals')
                  .where('status', isEqualTo: _selectedStatus)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 50,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading renewals',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 60,
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No $_selectedStatus renewals found',
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                // Process documents
                var docs = snapshot.data!.docs;
                
                // Apply search filter
                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _searchQuery.isEmpty ||
                      (data['name']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
                      (data['licenseNumber']?.toString().toLowerCase().contains(_searchQuery) ?? false) ||
                      (data['cnic']?.toString().toLowerCase().contains(_searchQuery) ?? false);
                }).toList();

                // Apply sorting
                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  
                  // Safely handle timestamps
                  Timestamp? aTimestamp = aData['requestDate'] as Timestamp?;
                  Timestamp? bTimestamp = bData['requestDate'] as Timestamp?;
                  
                  switch (_sortOption) {
                    case 'Oldest First':
                      return (aTimestamp ?? Timestamp.now())
                          .compareTo(bTimestamp ?? Timestamp.now());
                    case 'License Number':
                      return (aData['licenseNumber'] ?? '')
                          .compareTo(bData['licenseNumber'] ?? '');
                    case 'Name A-Z':
                      return (aData['name'] ?? '')
                          .compareTo(bData['name'] ?? '');
                    default: // Newest First
                      return (bTimestamp ?? Timestamp.now())
                          .compareTo(aTimestamp ?? Timestamp.now());
                  }
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results match your search',
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    
                    // Safely handle all fields
                    String name = data['name'] ?? 'No name';
                    String licenseNumber = data['licenseNumber'] ?? 'No license number';
                    String cnic = data['cnic'] ?? 'No CNIC';
                    String status = data['status'] ?? 'Pending';
                    
                    // Handle dates safely
                    DateTime? requestDate;
                    if (data['requestDate'] != null) {
                      requestDate = (data['requestDate'] as Timestamp).toDate();
                    }
                    
                    DateTime? lastUpdated;
                    if (data['lastUpdated'] != null) {
                      lastUpdated = (data['lastUpdated'] as Timestamp).toDate();
                    }
                    
                    String currentIssueDate = data['currentIssueDate'] ?? 'Not available';
                    String currentExpiryDate = data['currentExpiryDate'] ?? 'Not available';
                    String requestedExpiryDate = data['requestedExpiryDate'] ?? 'Not available';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with name and status
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar with first letter of name
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'N',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // License info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.badge_outlined,
                                            size: 16,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            licenseNumber,
                                            style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.pin_outlined,
                                            size: 16,
                                            color: colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            cnic,
                                            style: textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Status chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(status).withOpacity(0.5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getStatusIcon(status),
                                        size: 14,
                                        color: _getStatusColor(status),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          color: _getStatusColor(status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(),
                            ),
                            
                            // Renewal Details in a 2-column grid
                            Wrap(
                              spacing: 24,
                              runSpacing: 16,
                              children: [
                                _buildDetailItem(
                                  context, 
                                  Icons.calendar_today_outlined, 
                                  'Current Issue',
                                  currentIssueDate
                                ),
                                _buildDetailItem(
                                  context, 
                                  Icons.event_busy_outlined, 
                                  'Current Expiry',
                                  currentExpiryDate
                                ),
                                _buildDetailItem(
                                  context, 
                                  Icons.update_outlined, 
                                  'Requested Expiry',
                                  requestedExpiryDate
                                ),
                                if (requestDate != null)
                                  _buildDetailItem(
                                    context, 
                                    Icons.history_outlined, 
                                    'Requested On',
                                    DateFormat('MMM dd, yyyy').format(requestDate)
                                  ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Action Buttons
                            if (status == 'Pending') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _updateRenewalStatus(doc.id, 'Approved'),
                                      icon: const Icon(Icons.check_circle_outline),
                                      label: const Text('APPROVE'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _updateRenewalStatus(doc.id, 'Rejected'),
                                      icon: const Icon(Icons.cancel_outlined),
                                      label: const Text('REJECT'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (status == 'Approved') ...[
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateRenewalStatus(doc.id, 'Dispatched'),
                                  icon: const Icon(Icons.local_shipping_outlined),
                                  label: const Text('MARK AS DISPATCHED'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Dispatched':
        return const Color(0xFF6A1B9A); // Using the primary color from your theme
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.hourglass_top;
      case 'Approved':
        return Icons.check_circle;
      case 'Dispatched':
        return Icons.local_shipping;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}