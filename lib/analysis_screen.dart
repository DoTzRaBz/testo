import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/size.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<Map<String, dynamic>> _analysisData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalysisData();
  }

  Future<void> _fetchAnalysisData() async {
    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper();
      final transactions = await dbHelper.getTransactionsByDateRange(
        _startDate,
        _endDate,
      );
      _processAnalysisData(transactions);
    } catch (e) {
      print('Error fetching analysis data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to fetch analysis data. Please try again.',
              style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
            ),
            backgroundColor: TahuraColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(Sizes.medium),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _processAnalysisData(List<Map<String, dynamic>> transactions) {
    Map<String, double> dailyRevenue = {};

    for (var transaction in transactions) {
      String date = transaction['transaction_date'].split('T')[0];
      double amount = transaction['amount'] ?? 0.0;
      dailyRevenue[date] = (dailyRevenue[date] ?? 0) + amount;
    }

    setState(() {
      _analysisData = dailyRevenue.entries
          .map((entry) => {
                'date': entry.key,
                'revenue': entry.value,
              })
          .toList();
    });
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: TahuraColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchAnalysisData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Analisis Penggunaan Sistem',
          style: TahuraTextStyles.appBarTitle,
        )
            .animate()
            .fadeIn(duration: TahuraAnimations.medium)
            .slideX(begin: -0.2, end: 0),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range, color: Colors.white),
            onPressed: _showDateRangePicker,
          )
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideX(begin: 0.2, end: 0),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingState() : _buildAnalysisContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.all(Sizes.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: Sizes.buttonHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Sizes.radiusMedium),
              ),
            ),
            SizedBox(height: Sizes.medium),
            Container(
              height: ScreenUtils.getResponsiveHeight(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Sizes.radiusMedium),
              ),
            ),
            SizedBox(height: Sizes.medium),
            Container(
              height: ScreenUtils.getResponsiveHeight(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Sizes.radiusMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(Sizes.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeSection()
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideY(begin: 0.2, end: 0),
          SizedBox(height: Sizes.large),
          _buildRevenueChart()
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideY(begin: 0.3, end: 0),
          SizedBox(height: Sizes.large),
          _buildSummaryStatistics()
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideY(begin: 0.4, end: 0),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Container(
      padding: EdgeInsets.all(Sizes.medium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        boxShadow: TahuraShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Periode:',
            style: TahuraTextStyles.bodyText,
          ),
          SizedBox(height: Sizes.small),
          Text(
            '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
            style: TahuraTextStyles.screenTitle,
          ),
          SizedBox(height: Sizes.medium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showDateRangePicker,
              icon: Icon(Icons.date_range),
              label: Text('Ubah Periode'),
              style: TahuraButtons.primaryButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      height: ScreenUtils.getResponsiveHeight(40),
      padding: EdgeInsets.all(Sizes.medium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        boxShadow: TahuraShadows.medium,
      ),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
          majorGridLines: MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
          numberFormat: NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries>[
          AreaSeries<Map<String, dynamic>, String>(
            dataSource: _analysisData,
            xValueMapper: (data, _) =>
                DateFormat('dd MMM').format(DateTime.parse(data['date'])),
            yValueMapper: (data, _) => data['revenue'],
            name: 'Pendapatan',
            color: TahuraColors.primary.withOpacity(0.3),
            borderColor: TahuraColors.primary,
            borderWidth: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatistics() {
    double totalRevenue =
        _analysisData.fold(0, (sum, data) => sum + (data['revenue'] ?? 0));
    double averageRevenue =
        _analysisData.isEmpty ? 0 : totalRevenue / _analysisData.length;

    return Container(
      padding: EdgeInsets.all(Sizes.medium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        boxShadow: TahuraShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Statistik',
            style: TahuraTextStyles.screenTitle,
          ),
          SizedBox(height: Sizes.medium),
          _buildStatItem(
            'Total Pendapatan',
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(totalRevenue),
          ),
          _buildStatItem(
            'Rata-rata Harian',
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(averageRevenue),
          ),
          _buildStatItem(
            'Jumlah Transaksi',
            _analysisData.length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Sizes.small),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TahuraTextStyles.bodyText,
          ),
          Text(
            value,
            style: TahuraTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
