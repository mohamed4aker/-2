import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'customers_report_screen.dart';
import 'financial_report_screen.dart';
import 'inventory_report_screen.dart';
import 'sales_report_screen.dart';

/// مركز التقارير — كل تقارير المتجر في مكان واحد.
class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      (
        title: 'تقرير المبيعات',
        subtitle: 'المبيعات بالفترات والأكثر مبيعاً وحالات الطلبات',
        icon: Icons.trending_up,
        screen: const SalesReportScreen(),
      ),
      (
        title: 'التقرير المالي',
        subtitle: 'الإيرادات، المحصّل، المستحق، وطرق الدفع',
        icon: Icons.account_balance_wallet_outlined,
        screen: const FinancialReportScreen(),
      ),
      (
        title: 'تقرير المخزن',
        subtitle: 'قيمة البضاعة، النواقص، والبضاعة الراكدة',
        icon: Icons.inventory_2_outlined,
        screen: const InventoryReportScreen(),
      ),
      (
        title: 'تقرير العملاء',
        subtitle: 'أفضل العملاء، المدن، ومعدل تكرار الشراء',
        icon: Icons.people_outline,
        screen: const CustomersReportScreen(),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = reports[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text(report.title)),
                body: report.screen,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(report.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        report.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_back_ios_new, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}
