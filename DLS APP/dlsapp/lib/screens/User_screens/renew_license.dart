import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LicenseRenewalRequestScreen extends StatefulWidget {
  const LicenseRenewalRequestScreen({super.key});

  @override
  _LicenseRenewalRequestScreenState createState() =>
      _LicenseRenewalRequestScreenState();
}

class _LicenseRenewalRequestScreenState
    extends State<LicenseRenewalRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();
  final TextEditingController _issueDateController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _submitRenewalRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cnic = _cnicController.text.trim();
      final licenseNumber = _licenseNumberController.text.trim();
      final newExpiryDate = DateTime.now().add(Duration(days: 365 * 5));
      final formattedNewExpiryDate = DateFormat('yyyy-MM-dd').format(newExpiryDate);
      
      // Check if license already exists with this CNIC
      final licenseQuery = await FirebaseFirestore.instance
          .collection('licenses')
          .where('cnic', isEqualTo: cnic)
          .limit(1)
          .get();

      if (licenseQuery.docs.isNotEmpty) {
        final licenseDoc = licenseQuery.docs.first;
        final renewalRequest = licenseDoc['renewalRequest'];
        
        if (renewalRequest != null) {
          // Check if there is an existing request and its status
          final requestStatus = renewalRequest['status'];
          if (requestStatus == 'Pending') {
            _showError('You have already submitted a renewal request, waiting for completion.');
            return;
          } else if (requestStatus == 'Completed') {
            // Proceed with submitting the new request
            await _processRenewalRequest(licenseDoc);
          }
        } else {
          // If no renewal request exists, proceed with creating a new one
          await _processRenewalRequest(licenseDoc);
        }
      } else {
        // Create a new license entry if no record exists
        await _processRenewalRequest(null);
      }

      _showSuccess('Renewal request submitted successfully');
      _clearForm();
    } catch (e) {
      _showError('Error submitting request: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processRenewalRequest(DocumentSnapshot? licenseDoc) async {
    final cnic = _cnicController.text.trim();
    final licenseNumber = _licenseNumberController.text.trim();
    final newExpiryDate = DateTime.now().add(Duration(days: 365 * 5));
    final formattedNewExpiryDate = DateFormat('yyyy-MM-dd').format(newExpiryDate);

    final renewalData = {
      'name': _nameController.text.trim(),
      'cnic': cnic,
      'licenseNumber': licenseNumber,
      'currentIssueDate': _issueDateController.text,
      'currentExpiryDate': _expiryDateController.text,
      'requestedExpiryDate': formattedNewExpiryDate,
      'status': 'Pending',
      'requestDate': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    if (licenseDoc != null) {
      // Update existing license renewal request
      await licenseDoc.reference.update({
        'renewalRequest': renewalData,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Also add to renewals collection for tracking
      await FirebaseFirestore.instance.collection('license_renewals').add({
        ...renewalData,
        'licenseId': licenseDoc.id,
        'isUpdate': true,
      });
    } else {
      // Create new license entry
      final newLicenseRef = await FirebaseFirestore.instance.collection('licenses').add({
        'name': _nameController.text.trim(),
        'cnic': cnic,
        'licenseNumber': licenseNumber,
        'originalIssueDate': _issueDateController.text,
        'currentExpiryDate': _expiryDateController.text,
        'status': 'Pending Renewal',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'renewalRequest': renewalData,
      });

      // Add to renewals collection
      await FirebaseFirestore.instance.collection('license_renewals').add({
        ...renewalData,
        'licenseId': newLicenseRef.id,
        'isUpdate': false,
      });
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _cnicController.clear();
    _licenseNumberController.clear();
    _issueDateController.clear();
    _expiryDateController.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('License Renewal Request'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'License Renewal',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              SizedBox(height: 8),
              Text(
                'Fill the form to request license renewal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your full name' : null,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _cnicController,
                label: 'CNIC (without dashes)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter your CNIC';
                  if (value!.length != 13) return 'CNIC must be 13 digits';
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _licenseNumberController,
                label: 'License Number',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your license number' : null,
              ),
              SizedBox(height: 16),
              _buildDateField(
                context: context,
                controller: _issueDateController,
                label: 'Issue Date',
                validator: (value) => value?.isEmpty ?? true ? 'Please select issue date' : null,
              ),
              SizedBox(height: 16),
              _buildDateField(
                context: context,
                controller: _expiryDateController,
                label: 'Expiry Date',
                validator: (value) => value?.isEmpty ?? true ? 'Please select expiry date' : null,
              ),
              SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRenewalRequest,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'SUBMIT REQUEST',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context, controller),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _licenseNumberController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }
}
