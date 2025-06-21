import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class AppointmentStatusScreen extends StatefulWidget {
  const AppointmentStatusScreen({super.key});

  @override
  State<AppointmentStatusScreen> createState() => _AppointmentStatusScreenState();
}

class _AppointmentStatusScreenState extends State<AppointmentStatusScreen> {
  final TextEditingController _cnicController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _appointmentData;
  bool _isLoading = false;
  bool _notFound = false;

  Future<void> _checkAppointmentStatus() async {
    if (_cnicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your CNIC number'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Normalize the CNIC by removing any dashes
    String normalizedCnic = _cnicController.text.replaceAll('-', '').trim();

    setState(() {
      _isLoading = true;
      _notFound = false;
      _appointmentData = null;
    });

    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('cnic', isEqualTo: normalizedCnic)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _appointmentData = querySnapshot.docs.first.data();
        });
      } else {
        setState(() {
          _notFound = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching appointment: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cnicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Status'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface.withOpacity(0.8),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Check Your Appointment Status',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _cnicController,
                            decoration: InputDecoration(
                              labelText: 'Enter CNIC Number',
                              hintText: 'XXXXX-XXXXXXX-X',
                              prefixIcon: Icon(
                                Icons.credit_card_rounded,
                                color: colorScheme.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.outline,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: colorScheme.surface,
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(13),
                              _CnicInputFormatter(),
                            ],
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _checkAppointmentStatus,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              minimumSize: const Size(double.infinity, 54),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'CHECK STATUS',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                  else if (_notFound)
                    _buildNotFoundCard(colorScheme)
                  else if (_appointmentData != null)
                    _buildAppointmentDetailsCard(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: colorScheme.error.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'No appointment found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any appointment with the provided CNIC number. Please check the number and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentDetailsCard(ColorScheme colorScheme) {
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final createdAt = (_appointmentData!['createdAt'] as Timestamp).toDate();
    final appointmentDate = DateTime.parse(_appointmentData!['date']);

    // Format the CNIC for display (add dashes)
    final displayCnic = _appointmentData!['cnic'].length == 13
        ? '${_appointmentData!['cnic'].substring(0, 5)}-${_appointmentData!['cnic'].substring(5, 12)}-${_appointmentData!['cnic'].substring(12)}'
        : _appointmentData!['cnic'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                _buildStatusChip(_appointmentData!['status'], colorScheme),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(
              context,
              'Token Number',
              _appointmentData!['token'],
              icon: Icons.confirmation_number_rounded,
              colorScheme: colorScheme,
            ),
            _buildDetailRow(
              context,
              'Full Name',
              _appointmentData!['fullName'],
              icon: Icons.person_rounded,
              colorScheme: colorScheme,
            ),
            _buildDetailRow(
              context,
              'CNIC',
              displayCnic,
              icon: Icons.credit_card_rounded,
              colorScheme: colorScheme,
            ),
            _buildDetailRow(
              context,
              'Phone',
              _appointmentData!['phone'],
              icon: Icons.phone_rounded,
              colorScheme: colorScheme,
            ),
            const Divider(height: 32),
            _buildDetailRow(
              context,
              'Test Center',
              _appointmentData!['testCenter'],
              icon: Icons.location_on_rounded,
              colorScheme: colorScheme,
            ),
            _buildDetailRow(
              context,
              'Appointment Date',
              dateFormat.format(appointmentDate),
              icon: Icons.calendar_today_rounded,
              colorScheme: colorScheme,
            ),
            _buildDetailRow(
              context,
              'Time Slot',
              _appointmentData!['timeSlot'],
              icon: Icons.access_time_rounded,
              colorScheme: colorScheme,
            ),
            const Divider(height: 32),
            _buildDetailRow(
              context,
              'Requested On',
              DateFormat('MMMM dd, yyyy - hh:mm a').format(createdAt),
              icon: Icons.history_rounded,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'IMPORTANT NOTES',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNoteItem(
                    context,
                    'Bring this confirmation and original CNIC on appointment day',
                    Icons.badge_rounded,
                    colorScheme,
                  ),
                  _buildNoteItem(
                    context,
                    'Arrive 30 minutes before your scheduled time',
                    Icons.timer_rounded,
                    colorScheme,
                  ),
                  _buildNoteItem(
                    context,
                    'Late arrivals may result in appointment cancellation',
                    Icons.warning_rounded,
                    colorScheme,
                  ),
                  _buildNoteItem(
                    context,
                    'Dress code: Formal attire is required for photo session',
                    Icons.checkroom_rounded,
                    colorScheme,
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(
    BuildContext context,
    String text,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.primary.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 16,
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green.shade600;
      case 'rejected':
        return colorScheme.error;
      case 'completed':
        return colorScheme.primary;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}

class _CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length > 13) {
      return oldValue;
    }
    
    if (text.isEmpty) {
      return newValue;
    }
    
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 4 || i == 11) {
        buffer.write('-');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}