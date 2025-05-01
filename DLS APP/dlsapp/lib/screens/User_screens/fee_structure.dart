import 'package:flutter/material.dart';

class FeeStructureScreen extends StatelessWidget {
  const FeeStructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Structure'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeeTable(),
            const SizedBox(height: 24),
            _buildFixedFeeCharges(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'License Fee Structure',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A1B9A),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 12,
            dataRowMinHeight: 40,
            dataRowMaxHeight: 60,
            headingRowHeight: 60,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            headingRowColor: WidgetStateProperty.all(const Color(0xFF6A1B9A)),
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
              _buildDataRow('HTV + Motor Cycle', ['150', '100', 'N/A', '1060', '1660', '1560', '2460', '']),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(String category, List<String> values) {
    return DataRow(
      cells: [
        DataCell(Text(category, style: const TextStyle(fontWeight: FontWeight.bold))),
        ...values.map((value) => DataCell(Text(value))),
      ],
    );
  }

  Widget _buildFixedFeeCharges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fixed Fee Charges',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A1B9A),
          ),
        ),
        const SizedBox(height: 12),
        Table(
          border: TableBorder.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(2),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(
                color: Color(0xFF6A1B9A),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('#', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Fee (Rs.)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('7'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('TCS'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('(Karachi) Rs. 38'),
                      Text('(Outside Karachi) Rs. 55'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  TableRow _buildFixedFeeRow(String number, String service, String fee) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(number),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(service),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(fee),
        ),
      ],
    );
  }
}
