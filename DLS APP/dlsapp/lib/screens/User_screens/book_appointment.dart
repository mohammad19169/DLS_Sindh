import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedTestCenter;
  String? _selectedTimeSlot;
  DateTime? _selectedDate;

  final List<String> _testCenters = [
    'Karachi - Clifton Licensing Center',
    'Karachi - Korangi Licensing Center',
    'Karachi - Nazimabad Licensing Center',
    'Hyderabad - Tilak Incline Licensing Center',
    'Sukkur - Rohri Licensing Center',
  ];

  final List<String> _timeSlots = [
    '9:00 AM - 10:00 AM',
    '11:00 AM - 12:00 PM',
    '2:00 PM - 3:00 PM'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  Future<void> _submitAppointment() async {
    if (_formKey.currentState!.validate()) {
      try {
        final random = Random();
        final token = 'DL-${random.nextInt(9000) + 1000}-${DateTime.now().millisecondsSinceEpoch % 10000}';

        await FirebaseFirestore.instance.collection('appointments').add({
          'fullName': _nameController.text,
          'cnic': _cnicController.text,
          'phone': _phoneController.text,
          'testCenter': _selectedTestCenter,
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'timeSlot': _selectedTimeSlot,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'Pending',
          'userId': FirebaseAuth.instance.currentUser?.uid ?? 'guest',
          'token': token,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment booked!\nYour token is: $token'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Generate PDF ticket
        await _generatePdfTicket(token);

        // Clear form
        _nameController.clear();
        _cnicController.clear();
        _phoneController.clear();
        _dateController.clear();
        setState(() {
          _selectedTestCenter = null;
          _selectedTimeSlot = null;
          _selectedDate = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking appointment: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text('Please fill all fields'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ),
          pw.Text(
            ':',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Flexible(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdfTicket(String token) async {
    final pdf = pw.Document();
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/govlogo.png')).buffer.asUint8List(),
    );
    final font = await PdfGoogleFonts.nunitoSansRegular();
    final fontBold = await PdfGoogleFonts.nunitoSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.green, width: 2),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Image(logo, width: 60, height: 60),
                    pw.Column(
                      children: [
                        pw.Text(
                          'GOVERNMENT OF PAKISTAN',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green,
                          ),
                        ),
                        pw.Text(
                          'DRIVING LICENSE AUTHORITY',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Divider(thickness: 1.5, color: PdfColors.green),
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    'APPOINTMENT CONFIRMATION',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green.shade(800),
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green.shade(50),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Row(
                    children: [
                      pw.Text(
                        'APPOINTMENT TOKEN: ',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        token,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  'APPLICANT INFORMATION',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 12),
                _buildInfoRow('Full Name', _nameController.text),
                _buildInfoRow('CNIC Number', _cnicController.text),
                _buildInfoRow('Phone Number', _phoneController.text),
                pw.SizedBox(height: 16),
                pw.Text(
                  'APPOINTMENT DETAILS',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 12),
                _buildInfoRow('Test Center', _selectedTestCenter ?? ''),
                _buildInfoRow('Appointment Date', DateFormat('dd MMMM yyyy').format(_selectedDate!)),
                _buildInfoRow('Time Slot', _selectedTimeSlot ?? ''),
                _buildInfoRow('Issued On', DateFormat('dd MMMM yyyy - hh:mm a').format(DateTime.now())),
                pw.SizedBox(height: 24),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey.shade(200),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'IMPORTANT INSTRUCTIONS:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text('1. Bring this confirmation and original CNIC on appointment day', style: pw.TextStyle(fontSize: 10,color: PdfColors.white)),
                      pw.Text('2. Arrive 30 minutes before your scheduled time', style: pw.TextStyle(fontSize: 10,color: PdfColors.white)),
                      pw.Text('3. Late arrivals may result in appointment cancellation', style: pw.TextStyle(fontSize: 10,color: PdfColors.white)),
                      pw.Text('4. Dress code: Formal attire is required for photo session', style: pw.TextStyle(fontSize: 10,color: PdfColors.white)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    'Thank you for using our services',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey.shade(600),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'DL_Appointment_$token.pdf');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Driving Test Appointment'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Appointment Form',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildInputField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Please enter your full name' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              controller: _cnicController,
                              label: 'CNIC Number',
                              icon: Icons.credit_card_outlined,
                              hintText: '13 digits without dashes',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter your CNIC';
                                if (!RegExp(r'^\d{13}$').hasMatch(value)) {
                                  return 'Enter valid 13-digit CNIC';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone_android_outlined,
                              hintText: '03XX-XXXXXXX',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter phone number';
                                if (!RegExp(r'^03\d{2}-\d{7}$').hasMatch(value)) {
                                  return 'Enter valid phone (03XX-XXXXXXX)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              value: _selectedTestCenter,
                              items: _testCenters,
                              label: 'Select Test Center',
                              icon: Icons.location_on_outlined,
                              onChanged: (value) => setState(() => _selectedTestCenter = value),
                              validator: (value) => value == null ? 'Please select test center' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              controller: _dateController,
                              label: 'Select Date',
                              icon: Icons.calendar_today_outlined,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) => value == null || value.isEmpty ? 'Please select date' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              value: _selectedTimeSlot,
                              items: _timeSlots,
                              label: 'Select Time Slot',
                              icon: Icons.access_time_outlined,
                              onChanged: (value) => setState(() => _selectedTimeSlot = value),
                              validator: (value) => value == null ? 'Please select time slot' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: Colors.blue.shade200,
                  ),
                  child: const Text(
                    'BOOK APPOINTMENT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validator,
      onTap: onTap,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true, // Add this to prevent overflow
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: TextStyle(color: Colors.grey.shade800),
            overflow: TextOverflow.ellipsis, // Add ellipsis for long text
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      dropdownColor: Colors.white,
      icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade600),
      borderRadius: BorderRadius.circular(10),
      style: TextStyle(color: Colors.grey.shade800),
    );
  }
}