import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'dart:io';

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

  File? _cnicFrontImage;
  File? _cnicBackImage;
  bool _isLoading = false;
  bool _isUploadingImages = false;

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

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _cnicFrontImage = File(pickedFile.path);
        } else {
          _cnicBackImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImage(File image, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      _showError('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitRenewalRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cnicFrontImage == null || _cnicBackImage == null) {
      _showError('Please upload both CNIC front and back images');
      return;
    }

    setState(() {
      _isLoading = true;
      _isUploadingImages = true;
    });

    try {
      // Upload images first
      final cnic = _cnicController.text.trim();
      final frontUrl = await _uploadImage(_cnicFrontImage!, 'cnic_images/${cnic}_front.jpg');
      final backUrl = await _uploadImage(_cnicBackImage!, 'cnic_images/${cnic}_back.jpg');

      if (frontUrl == null || backUrl == null) {
        _showError('Failed to upload CNIC images');
        return;
      }

      setState(() => _isUploadingImages = false);

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
            await _processRenewalRequest(licenseDoc, frontUrl, backUrl);
          }
        } else {
          // If no renewal request exists, proceed with creating a new one
          await _processRenewalRequest(licenseDoc, frontUrl, backUrl);
        }
      } else {
        // Create a new license entry if no record exists
        await _processRenewalRequest(null, frontUrl, backUrl);
      }

      _showSuccess('Renewal request submitted successfully');
      _clearForm();
    } catch (e) {
      _showError('Error submitting request: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processRenewalRequest(DocumentSnapshot? licenseDoc, String frontUrl, String backUrl) async {
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
      'cnicFrontImage': frontUrl,
      'cnicBackImage': backUrl,
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
    setState(() {
      _cnicFrontImage = null;
      _cnicBackImage = null;
    });
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

  Widget _buildImageUploadField(String label, bool isFront) {
    final image = isFront ? _cnicFrontImage : _cnicBackImage;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(isFront),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: image == null ? Colors.grey.shade300 : Color(0xFF6A1B9A),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: image == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 40,
                          color: Color(0xFF6A1B9A),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to upload',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6A1B9A),
          primary: Color(0xFF6A1B9A),
          secondary: Color(0xFFF3E5F5),
          surface: Color(0xFFFFFDE7),
        ),
        scaffoldBackgroundColor: Color(0xFFFFFDE7),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('License Renewal Request'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFDE7),
            image: DecorationImage(
              image: AssetImage('assets/images/license_bg.png'),
              opacity: 0.05,
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    color: Color(0xFFF3E5F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.refresh,
                                color: Color(0xFF6A1B9A),
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'License Renewal',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6A1B9A),
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Fill the form to request license renewal',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.black54,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildFormField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter your full name' : null,
                  ),
                  SizedBox(height: 16),
                  _buildFormField(
                    controller: _cnicController,
                    label: 'CNIC (without dashes)',
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Please enter your CNIC';
                      if (value!.length != 13) return 'CNIC must be 13 digits';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _buildFormField(
                    controller: _licenseNumberController,
                    label: 'License Number',
                    icon: Icons.badge,
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter your license number' : null,
                  ),
                  SizedBox(height: 16),
                  _buildDateField(
                    context: context,
                    controller: _issueDateController,
                    label: 'Issue Date',
                    icon: Icons.event,
                    validator: (value) => value?.isEmpty ?? true ? 'Please select issue date' : null,
                  ),
                  SizedBox(height: 16),
                  _buildDateField(
                    context: context,
                    controller: _expiryDateController,
                    label: 'Expiry Date',
                    icon: Icons.event_busy,
                    validator: (value) => value?.isEmpty ?? true ? 'Please select expiry date' : null,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'CNIC Images',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Color(0xFF6A1B9A),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload clear images of your CNIC (front and back)',
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 16),
                  _buildImageUploadField('CNIC Front Side', true),
                  SizedBox(height: 16),
                  _buildImageUploadField('CNIC Back Side', false),
                  SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6A1B9A).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRenewalRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isUploadingImages)
                    Text('Uploading Images...')
                  else
                    Text('Processing...'),
                  SizedBox(width: 8),
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text(
                    'SUBMIT REQUEST',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: Color(0xFF6A1B9A),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF6A1B9A), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          fillColor: Colors.white,
          filled: true,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: Color(0xFF6A1B9A),
          ),
          suffixIcon: Icon(
            Icons.calendar_today,
            color: Color(0xFF6A1B9A),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF6A1B9A), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          fillColor: Colors.white,
          filled: true,
        ),
        onTap: () => _selectDate(context, controller),
        validator: validator,
      ),
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