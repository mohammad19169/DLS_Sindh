import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  bool showPhoneDetails = false;
  bool showEmailDetails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support & Help'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 30),
            _buildSectionTitle('Contact Support'),
            const SizedBox(height: 15),
            _buildExpandableCard(
              icon: Icons.phone,
              title: 'Call Support',
              subtitle: 'Available 9AM - 5PM, Mon-Fri',
              expanded: showPhoneDetails,
              onTap: () {
                setState(() {
                  showPhoneDetails = !showPhoneDetails;
                  showEmailDetails = false;
                });
              },
              detailContent: const Text(
                'Phone Number:\n0341 1234569',
                style: TextStyle(fontSize: 16),
              ),
            ),
            _buildExpandableCard(
              icon: Icons.email,
              title: 'Email Us',
              subtitle: 'Response within 24 hours',
              expanded: showEmailDetails,
              onTap: () {
                setState(() {
                  showEmailDetails = !showEmailDetails;
                  showPhoneDetails = false;
                });
              },
              detailContent: const Text(
                'Email:\numerm7783@gmail.com',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Frequently Asked Questions'),
            const SizedBox(height: 15),
            _buildFaqItem(
              question: 'How to book a driving license appointment?',
              answer: '1. Go to Book Appointment section\n'
                  '2. Select your preferred date and time\n'
                  '3. Complete the application form\n'
                  '4. Submit required documents\n'
                  '5. Receive confirmation via SMS/email',
            ),
            _buildFaqItem(
              question: 'What documents are required for license application?',
              answer: '- Original CNIC\n'
                  '- Copy of CNIC\n'
                  '- 2 passport size photographs\n'
                  '- Medical certificate from authorized doctor\n'
                  '- Existing license (if renewing)',
            ),
            _buildFaqItem(
              question: 'How long does license verification take?',
              answer: 'License verification typically takes 24-48 hours. '
                  'You can check status in the Application Status section.',
            ),
            _buildFaqItem(
              question: 'What are the fees for license renewal?',
              answer: 'Fees vary by license type and duration. '
                  'Check the Fee Structure section for complete details.',
            ),
            _buildFaqItem(
              question: 'My application was rejected. What should I do?',
              answer: 'If your application was rejected, you will receive '
                  'a reason via SMS. You may reapply after addressing '
                  'the mentioned issues or visit your nearest licensing office.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 2,
      color: const Color(0xFFF3E5F5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.help_center, size: 50, color: Color(0xFF6A1B9A)),
            const SizedBox(height: 10),
            Text(
              'Need Assistance?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contact our support team or browse common questions',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6A1B9A),
      ),
    );
  }

  Widget _buildExpandableCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool expanded,
    required VoidCallback onTap,
    required Widget detailContent,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6A1B9A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF6A1B9A)),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle),
            trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            onTap: onTap,
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: detailContent,
            ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}
