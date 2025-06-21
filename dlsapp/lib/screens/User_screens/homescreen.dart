import 'package:dlsapp/screens/User_screens/VerifyLicenseScreen.dart';
import 'package:dlsapp/screens/User_screens/appointment_status.dart';
import 'package:dlsapp/screens/User_screens/book_appointment.dart';
import 'package:dlsapp/screens/User_screens/fee_structure.dart';
import 'package:dlsapp/screens/User_screens/renew_license.dart';
import 'package:dlsapp/screens/User_screens/signin.dart';
import 'package:dlsapp/screens/User_screens/support.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      appBar: AppBar(
        title: const Text('Driving License Sindh'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildWelcomeCard(context),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GridView.count(
                        crossAxisCount: 2,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1, // Slightly adjusted for better spacing
                        children: [
                          _buildDashboardCard(
                            context,
                            Icons.calendar_month, // Updated more modern calendar icon
                            'Book\nAppointment',
                            const Color(0xFF6A1B9A),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>BookAppointmentScreen()));
                            },
                          ),
                          _buildDashboardCard(
                            context,
                            Icons.pending_actions, // Better represents application status
                            'Application\nStatus',
                            const Color(0xFFAB47BC),
                            onTap: () {
                              Navigator.push(context,MaterialPageRoute(builder:(context)=>AppointmentStatusScreen()));
                            },
                          ),
                          _buildDashboardCard(
                            context,
                            Icons.how_to_reg, // Better represents verification
                            'Verify\nLicense',
                            const Color(0xFF7E57C2),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>VerifyLicenseScreen()));
                            },
                          ),
                          _buildDashboardCard(
                            context,
                            Icons.loop, // Better icon for renewal
                            'Renew\nLicense',
                            const Color(0xFF9575CD),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>LicenseRenewalRequestScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              Icons.support_agent, // Better support icon
                              'Support/Help',
                              const Color(0xFF6A1B9A),
                              onTap: () {
                                Navigator.push(context,MaterialPageRoute(builder: (context) => SupportScreen(),));
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              Icons.receipt_long, // Better fee structure icon
                              'Fee Structure',
                              const Color(0xFFAB47BC),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>FeeStructureScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFFAB47BC),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.drive_eta, color: Colors.white, size: 32), // Updated car icon
                const SizedBox(width: 10),
                const Flexible(
                  child: Text(
                    'Welcome!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.event_available, color: Colors.white70, size: 24), // Updated icon
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Book your driving license appointment easily and efficiently.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.white70, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Manage your license applications and renewals in one place.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>SignInScreen()));
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}