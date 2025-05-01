import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VerifyLicenseScreen extends StatefulWidget {
  const VerifyLicenseScreen({super.key});

  @override
  State<VerifyLicenseScreen> createState() => _VerifyLicenseScreenState();
}

class _VerifyLicenseScreenState extends State<VerifyLicenseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _licenseData;
  bool _isLoading = false;
  bool _notFound = false;

  Future<void> _verifyLicense() async {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter CNIC or License Number'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _notFound = false;
      _licenseData = null;
    });

    try {
      String input = _searchController.text.trim().replaceAll('-', '');

      final querySnapshot = await _firestore.collection('licenses').get();

      DocumentSnapshot? matchedDoc;
      for (var doc in querySnapshot.docs) {
        String docCnic = (doc['cnic'] ?? '').toString().replaceAll('-', '');
        String docLicenseNumber = (doc['licenseNumber'] ?? '').toString();
        if (docCnic == input || docLicenseNumber == input) {
          matchedDoc = doc;
          break;
        }
      }

      if (matchedDoc != null) {
        var licenseData = matchedDoc.data();
        if (licenseData != null) {
          setState(() {
            _licenseData = licenseData as Map<String, dynamic>;
          });
        } else {
          setState(() {
            _notFound = true;
          });
        }
      } else {
        setState(() {
          _notFound = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying license: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        title: const Text('Verify License'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Verify Your License',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Enter CNIC or License Number',
                          prefixIcon: Icon(Icons.search, 
                            color: theme.colorScheme.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          floatingLabelStyle: TextStyle(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _verifyLicense,
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.onPrimary,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'VERIFY LICENSE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )
              else if (_notFound)
                _buildNotFoundCard(theme)
              else if (_licenseData != null)
                _buildLicenseDetailsCard(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'No License Found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No license found for the entered details. Please verify the information and try again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseDetailsCard(ThemeData theme) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    final issueDateStr = _licenseData!['originalIssueDate']?.toString() ?? '';
    final expiryDateStr = _licenseData!['expiryDate']?.toString() ?? '';
    final lastUpdated = _licenseData!['lastUpdated'] is Timestamp
        ? (_licenseData!['lastUpdated'] as Timestamp).toDate()
        : null;

    final issueDate = DateTime.tryParse(issueDateStr) ?? DateTime.now();
    final expiryDate = DateTime.tryParse(expiryDateStr) ?? DateTime.now().add(const Duration(days: 365 * 5));

    final isLicenseExpired = expiryDate.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LICENSE DETAILS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Icon(
                  Icons.verified_rounded,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            Divider(
              color: theme.colorScheme.primary.withOpacity(0.2),
              thickness: 1.5,
              height: 32,
            ),
            _buildDetailRow(theme, 'Full Name', _licenseData!['name'] ?? 'Not available'),
            _buildDetailRow(theme, 'CNIC', _licenseData!['cnic'] ?? 'Not available'),
            _buildDetailRow(theme, 'License Number', _licenseData!['licenseNumber'] ?? 'Not available'),
            _buildDetailRow(theme, 'Issue Date', dateFormat.format(issueDate)),
            _buildDetailRow(
              theme, 
              'Expiry Date', 
              dateFormat.format(expiryDate),
              isExpired: isLicenseExpired,
            ),
            if (lastUpdated != null)
              _buildDetailRow(theme, 'Last Updated', dateFormat.format(lastUpdated)),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_licenseData!['status'] ?? 'Unknown'),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _licenseData!['status'] ?? 'Unknown',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (isLicenseExpired) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This license has expired. Please renew your license.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value, {bool isExpired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: isExpired ? theme.colorScheme.error : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade600;
      case 'dispatched':
        return Colors.teal.shade600;
      case 'suspended':
        return Colors.orange.shade700;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}