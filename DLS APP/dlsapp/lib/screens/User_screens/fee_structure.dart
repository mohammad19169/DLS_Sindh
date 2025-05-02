import 'package:flutter/material.dart';

class FeeStructureScreen extends StatelessWidget {
  const FeeStructureScreen({super.key});

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
          title: const Text('Fee Structure'),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  title: 'License Fee Structure',
                  icon: Icons.attach_money,
                ),
                const SizedBox(height: 16),
                _buildFeeTable(),
                const SizedBox(height: 32),
                _buildSectionHeader(
                  title: 'Fixed Fee Charges',
                  icon: Icons.receipt_long,
                ),
                const SizedBox(height: 16),
                _buildFixedFeeCharges(),
                const SizedBox(height: 24),
                _buildNoteCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Card(
      elevation: 0,
      color: Color(0xFFF3E5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Color(0xFF6A1B9A),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 64,
            headingRowHeight: 64,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
            headingRowColor: WidgetStateProperty.all(const Color(0xFF6A1B9A)),
            dataRowColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? Color(0xFFF3E5F5)
                  : null;
            }),
            columns: const [
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('New\nLearner')),
              DataColumn(label: Text('Renew\nLearner')),
              DataColumn(label: Text('3 Year\nPerm')),
              DataColumn(label: Text('5 Year\nPerm')),
              DataColumn(label: Text('3 Year\nRenew')),
              DataColumn(label: Text('5 Year\nRenew')),
              DataColumn(label: Text('3 Year\nLate')),
              DataColumn(label: Text('5 Year\nLate')),
            ],
            rows: [
              _buildDataRow('Motor Cycle', ['50', '100', '510', '660', '310', '460', '435', '660']),
              _buildDataRow('Car', ['100', '100', '960', '1260', '560', '860', '810', '1260']),
              _buildDataRow('Car + Motor Cycle', ['150', '100', '1410', '1860', '810', '1260', '1185', '1860']),
              _buildDataRow('MCR', ['100', '100', '960', '1260', '560', '860', '810', '1260']),
              _buildDataRow('LTV', ['100', '100', '960', '1260', '560', '860', '810', '1260']),
              _buildDataRow('LTV + Motor Cycle', ['150', '100', '1410', '1860', '810', '1260', '1185', '1860']),
              _buildDataRow('HTV', ['100', '100', '460', '460', '810', '1260', '1185', '1860']),
              _buildDataRow('HTV + Motor Cycle', ['150', '100', 'N/A', '1060', '1660', '1560', '2460', 'N/A']),
            ],
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(String category, List<String> values) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            category,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
        ),
        ...values.map((value) => DataCell(
              Text(
                value,
                style: TextStyle(
                  fontWeight: value.contains('/') ? FontWeight.w300 : null,
                  color: value == 'N/A' ? Colors.red.shade300 : Colors.black87,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildFixedFeeCharges() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade200),
            verticalInside: BorderSide(color: Colors.grey.shade200),
          ),
          columnWidths: const {
            0: FixedColumnWidth(40),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Color(0xFF6A1B9A),
              ),
              children: [
                _buildHeaderCell('#'),
                _buildHeaderCell('Service'),
                _buildHeaderCell('Fee (Rs.)'),
              ],
            ),
            _buildFixedFeeRow('1', 'Lamination', '250'),
            _buildFixedFeeRow('2', 'Nadra', '65'),
            _buildFixedFeeRow('3', 'Medical', '100'),
            _buildFixedFeeRow('4', 'Correction', '310'),
            _buildFixedFeeRow('5', 'Duplicate', '800'),
            _buildFixedFeeRow('6', 'PSV', '500'),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(child: Text('7')),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('TCS'),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('(Karachi) Rs. 38'),
                      SizedBox(height: 4),
                      Text('(Outside Karachi) Rs. 55'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: text == '#' ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  TableRow _buildFixedFeeRow(String number, String service, String fee) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(child: Text(number)),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(service),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            fee,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard() {
    return Card(
      elevation: 0,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.amber.shade800,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Fees are subject to change without prior notice. Please confirm with the department before making a payment.',
                style: TextStyle(
                  color: Colors.amber.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}