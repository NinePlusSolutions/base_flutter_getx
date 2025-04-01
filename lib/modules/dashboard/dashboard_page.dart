import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_getx_boilerplate/models/dashboard_models.dart';
import 'package:flutter_getx_boilerplate/shared/constants/colors.dart';
import 'package:flutter_getx_boilerplate/theme/text_theme.dart';

class DashboardPage extends StatelessWidget {
  final DashboardData data = DashboardData.getSampleData();

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: Typo.h2.copyWith(color: ColorConstants.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPersonnelChangesCard(),
            const SizedBox(height: 20),
            _buildPersonnelChangesChart(),
            const SizedBox(height: 20),
            _buildSeniorityCard(),
            const SizedBox(height: 20),
            _buildSeniorityChart(),
            const SizedBox(height: 20),
            _buildDepartmentStructureCard(),
            const SizedBox(height: 20),
            _buildDepartmentPieChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelChangesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Báo Cáo Thay Đổi Nhân Sự (Thành Viên)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Tháng')),
                  DataColumn(label: Text('Số Lượng\nĐầu Tháng')),
                  DataColumn(label: Text('Tuyển Dụng\nMới')),
                  DataColumn(label: Text('Nghỉ Việc')),
                  DataColumn(label: Text('Số Lượng\nCuối Tháng')),
                ],
                rows: data.monthlyData.entries.map((entry) {
                  final month = entry.key;
                  final monthData = entry.value;
                  return DataRow(cells: [
                    DataCell(Text('Tháng $month')),
                    DataCell(Text(monthData.employeeBegin.toString())),
                    DataCell(Text(monthData.employeeNewRecruits.toString())),
                    DataCell(Text(monthData.employeeLeave.toString())),
                    DataCell(Text(monthData.employeeEnd.toString())),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeniorityCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Báo Cáo Nhân Sự Theo Thâm Niên (Thành Viên)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Thâm Niên')),
                  DataColumn(label: Text('Số Lượng')),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('< 1 Năm')),
                    DataCell(Text(data.seniorityData.lessOneYear.toString())),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('1 Năm')),
                    DataCell(Text(data.seniorityData.oneYear.toString())),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('2 Năm')),
                    DataCell(Text(data.seniorityData.twoYear.toString())),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('3 Năm')),
                    DataCell(Text(data.seniorityData.threeYear.toString())),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('4 Năm')),
                    DataCell(Text(data.seniorityData.forYear.toString())),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('> 4 Năm')),
                    DataCell(
                        Text(data.seniorityData.greaterFiveYear.toString())),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentStructureCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Báo Cáo Về Cơ Cấu Nhân Sự Theo Bộ Phận (Thành Viên)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Bộ Phận')),
                  DataColumn(label: Text('Nhân Viên')),
                  DataColumn(label: Text('Thực Tập')),
                  DataColumn(label: Text('Tổng')),
                ],
                rows: data.departmentData.entries.map((entry) {
                  final department = entry.key;
                  final deptData = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(department)),
                    DataCell(Text(deptData.totalEmployee.toString())),
                    DataCell(Text(deptData.totalIntership.toString())),
                    DataCell(Text(deptData.total.toString())),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonnelChangesChart() {
    final barGroups = data.monthlyData.entries.map((entry) {
      final month = int.parse(entry.key);
      final monthData = entry.value;

      final beginHeight = monthData.employeeBegin.toDouble();
      final newHeight = monthData.employeeNewRecruits.toDouble();
      final leaveHeight = monthData.employeeLeave.toDouble();
      final endHeight = monthData.employeeEnd.toDouble();

      return BarChartGroupData(
        x: month - 1,
        barRods: [
          BarChartRodData(
            toY: beginHeight + newHeight + leaveHeight + endHeight,
            width: 22,
            rodStackItems: [
              BarChartRodStackItem(
                0,
                beginHeight,
                Colors.blue,
              ),
              BarChartRodStackItem(
                beginHeight,
                beginHeight + newHeight,
                Colors.green,
              ),
              BarChartRodStackItem(
                beginHeight + newHeight,
                beginHeight + newHeight + leaveHeight,
                Colors.red,
              ),
              BarChartRodStackItem(
                beginHeight + newHeight + leaveHeight,
                beginHeight + newHeight + leaveHeight + endHeight,
                Colors.purple,
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.zero),
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biểu Đồ Báo Cáo Về Thay Đổi Nhân Sự (Thành Viên)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 7,
                  barGroups: barGroups,
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value < data.monthlyData.length) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('T${(value + 1).toInt()}'),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  groupsSpace: 20,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final monthData =
                        data.monthlyData[(groupIndex + 1).toString()];
                        return BarTooltipItem(
                          'Đầu tháng: ${monthData?.employeeBegin}\n'
                              'Tuyển mới: ${monthData?.employeeNewRecruits}\n'
                              'Nghỉ việc: ${monthData?.employeeLeave}\n'
                              'Cuối tháng: ${monthData?.employeeEnd}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem('Đầu tháng', Colors.blue),
                _buildLegendItem('Tuyển mới', Colors.green),
                _buildLegendItem('Nghỉ việc', Colors.red),
                _buildLegendItem('Cuối tháng', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeniorityChart() {
    final seniorityData = [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: data.seniorityData.lessOneYear.toDouble(),
            color: Colors.blue,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: data.seniorityData.oneYear.toDouble(),
            color: Colors.blue,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: data.seniorityData.twoYear.toDouble(),
            color: Colors.blue,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: data.seniorityData.threeYear.toDouble(),
            color: Colors.blue,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(
            toY: data.seniorityData.forYear.toDouble(),
            color: Colors.blue,
            width: 20,
          ),
        ],
      ),
      BarChartGroupData(
        x: 5,
        barRods: [
          BarChartRodData(
            toY: data.seniorityData.greaterFiveYear.toDouble(),
            color: Colors.blue,
            width: 20,
          ),
        ],
      ),
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biểu Đồ Báo Cáo Về Nhân Sự Theo Thâm Niên (Thành Viên)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 2,
                  barGroups: seniorityData,
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = [
                            '<1 Năm',
                            '1 Năm',
                            '2 Năm',
                            '3 Năm',
                            '4 Năm',
                            '>4 Năm'
                          ];
                          if (value >= 0 && value < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                labels[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentPieChart() {
    final List<PieChartSectionData> sections =
    data.departmentData.entries.map((entry) {
      final department = entry.key;
      final deptData = entry.value;
      final double percentage = deptData.total > 0
          ? (deptData.total /
          data.departmentData.values
              .fold(0, (sum, item) => sum + item.total)) *
          100
          : 0;

      return PieChartSectionData(
        color: department == "Manager" ? Colors.green : Colors.blue,
        value: deptData.total.toDouble(),
        title: '$department\n${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biểu Đồ Tròn Về Cơ Cấu Nhân Sự Theo Nhóm (Thành Viên)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: data.departmentData.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildLegendItem(
                    entry.key,
                    entry.key == "Manager" ? Colors.green : Colors.blue,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
