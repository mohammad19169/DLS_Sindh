import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  bool showPhoneDetails = false;
  bool showEmailDetails = false;

  // Function to handle phone calls
  Future<void> _makePhoneCall() async {
    const phoneNumber = '03411234569';
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }

  // Open email app directly
  Future<void> _openEmailApp() async {
    final email = 'umerm7783@gmail.com';
    final subject = 'Support Request from Driving License App';
    
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject},
    );
    
    try {
      await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      appBar: AppBar(
        title: const Text('Support & Help'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 25),
              _buildSectionTitle('Contact Support'),
              const SizedBox(height: 15),
              _buildExpandableCard(
                icon: Icons.headset_mic,
                title: 'Call Support',
                subtitle: 'Available 9AM - 5PM, Mon-Fri',
                expanded: showPhoneDetails,
                onTap: () {
                  setState(() {
                    showPhoneDetails = !showPhoneDetails;
                    if (showPhoneDetails) showEmailDetails = false;
                  });
                },
                detailContent: Column(
                  children: [
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.call, size: 20),
                      label: const Text('Call Support Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _makePhoneCall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Our representative will assist you with your queries',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              _buildExpandableCard(
                icon: Icons.mail_outline,
                title: 'Email Support',
                subtitle: 'Response within 24 hours',
                expanded: showEmailDetails,
                onTap: () {
                  setState(() {
                    showEmailDetails = !showEmailDetails;
                    if (showEmailDetails) showPhoneDetails = false;
                  });
                },
                detailContent: Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.email, color: Color(0xFF6A1B9A)),
                              const SizedBox(width: 10),
                              const Text(
                                'umerm7783@gmail.com',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Our support team is ready to help you',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new, size: 20),
                      label: const Text('Open Gmail'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _openEmailApp,
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'We typically respond to all inquiries within 24 hours',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
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
                answer: '• Original CNIC\n'
                    '• Copy of CNIC\n'
                    '• 2 passport size photographs\n'
                    '• Medical certificate from authorized doctor\n'
                    '• Existing license (if renewing)',
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
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFF3E5F5),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.support_agent, size: 50, color: Color(0xFF6A1B9A)),
            const SizedBox(height: 12),
            Text(
              'Need Assistance?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Contact our support team or browse common questions below',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6A1B9A),
        ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
            title: Text(
              title, 
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: expanded ? const Color(0xFF6A1B9A).withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF6A1B9A),
                ),
              ),
            ),
            onTap: onTap,
          ),
          if (expanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: detailContent,
            ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 1,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            question, 
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              answer, 
              style: TextStyle(
                color: Colors.black87,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}