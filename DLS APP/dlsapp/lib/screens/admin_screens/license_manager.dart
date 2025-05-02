import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAddLicenseScreen extends StatefulWidget {
  const AdminAddLicenseScreen({super.key});

  @override
  State<AdminAddLicenseScreen> createState() => _AdminAddLicenseScreenState();
}

class _AdminAddLicenseScreenState extends State<AdminAddLicenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _originalIssueDateController = TextEditingController();
  final TextEditingController _currentExpiryDateController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  String _status = 'Active';
  bool _isLoading = false;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _cnicController.dispose();
    _nameController.dispose();
    _licenseNumberController.dispose();
    _originalIssueDateController.dispose();
    _currentExpiryDateController.dispose();
    _expiryDateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _addLicense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final now = Timestamp.now();

      await _firestore.collection('licenses').add({
        'cnic': _cnicController.text.trim(),
        'name': _nameController.text.trim(),
        'licenseNumber': _licenseNumberController.text.trim(),
        'originalIssueDate': _originalIssueDateController.text.trim(),
        'currentExpiryDate': _currentExpiryDateController.text.trim(),
        'expiryDate': _expiryDateController.text.trim(),
        'status': _status,
        'createdAt': now,
        'lastUpdated': now,
        'renewalRequest': {
          'status': 'Dispatched',
          'lastUpdated': now,
        },
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('License added successfully!'),
            ],
          ),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Clear all form fields
      setState(() {
  _cnicController.text = '';
  _nameController.text = '';
  _licenseNumberController.text = '';
  _originalIssueDateController.text = '';
  _currentExpiryDateController.text = '';
  _expiryDateController.text = '';
  _status = 'Active';
});

      
      // Optional: Return focus to the first field for next entry
      FocusScope.of(context).requestFocus(FocusNode());
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Error adding license: $e')),
            ],
          ),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New License'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              Colors.white,
            ],
            stops: const [0.0, 0.6],
          ),
        ),
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Card(
                        margin: const EdgeInsets.only(bottom: 24),
                        elevation: 0,
                        color: colorScheme.secondary.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'License Information',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enter all required details to register a new license in the system',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Form Fields
                      _buildSectionTitle(context, 'Personal Details'),
                      _buildTextField(
                        controller: _cnicController,
                        label: 'CNIC (without dashes)',
                        prefixIcon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter CNIC';
                          if (value.length != 13) return 'CNIC must be 13 digits';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        prefixIcon: Icons.person,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter name';
                          return null;
                        },
                      ),
                      
                      _buildSectionTitle(context, 'License Details'),
                      _buildTextField(
                        controller: _licenseNumberController,
                        label: 'License Number (DL-XXXX-XXXX)',
                        prefixIcon: Icons.badge,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter license number';
                          if (!RegExp(r'^DL-\d{4}-\d{4}$').hasMatch(value)) {
                            return 'Format: DL-1234-5678';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        controller: _originalIssueDateController,
                        label: 'Original Issue Date',
                        prefixIcon: Icons.event_available,
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        controller: _currentExpiryDateController,
                        label: 'Current Expiry Date',
                        prefixIcon: Icons.event_busy,
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        controller: _expiryDateController,
                        label: 'New Expiry Date',
                        prefixIcon: Icons.update,
                      ),
                      const SizedBox(height: 16),
                      _buildStatusDropdown(),
                      
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required FormFieldValidator<String> validator,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      readOnly: true,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please select a date';
        return null;
      },
      onTap: () => _selectDate(context, controller),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _status,
      decoration: InputDecoration(
        labelText: 'License Status',
        prefixIcon: const Icon(Icons.verified_user),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      items: [
        _buildDropdownItem('Active', Icons.check_circle, Colors.green),
        _buildDropdownItem('Expired', Icons.access_time_filled, Colors.orange),
        _buildDropdownItem('Suspended', Icons.cancel, Colors.red),
      ],
      onChanged: (value) {
        setState(() {
          _status = value!;
        });
      },
      icon: const Icon(Icons.arrow_drop_down_circle),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, IconData icon, Color color) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _addLicense,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
      ),
      child: _isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Processing...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_alt, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Add License',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
    );
  }
}