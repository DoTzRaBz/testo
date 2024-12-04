import 'package:flutter/material.dart';
import 'package:myapp/utils/size.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, dynamic>> transactions = [];
  String? currentUserEmail;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getUserEmail();
    await fetchTransactionsWithUsers();
  }

  Future<void> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserEmail = prefs.getString('userEmail');
    });
  }

  Future<void> fetchTransactionsWithUsers() async {
    try {
      final db = DatabaseHelper();
      List<Map<String, dynamic>> allTransactions =
          await db.getAllTransactions();

      setState(() {
        transactions = allTransactions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching transactions: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load transactions. Please try again.',
              style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
            ),
            backgroundColor: TahuraColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(Sizes.medium),
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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
          'Laporan Transaksi',
          style: TahuraTextStyles.appBarTitle,
        )
            .animate()
            .fadeIn(duration: TahuraAnimations.medium)
            .slideX(begin: -0.2, end: 0),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _selectDate(context),
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
          child: _isLoading ? _buildLoadingState() : _buildReportContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(Sizes.medium),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: Sizes.medium),
          child: Container(
            height: ScreenUtils.getResponsiveHeight(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Sizes.radiusMedium),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    final filteredTransactions = transactions.where((transaction) {
      final transactionDate = DateTime.parse(transaction['transaction_date']);
      return transactionDate.year == _selectedDate.year &&
          transactionDate.month == _selectedDate.month &&
          transactionDate.day == _selectedDate.day;
    }).toList();

    return Column(
      children: [
        _buildSummaryCard(filteredTransactions),
        Expanded(
          child: _buildTransactionsList(filteredTransactions),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: Sizes.iconXLarge * 2,
            color: Colors.white54,
          ).animate().fadeIn(duration: TahuraAnimations.medium).scale(),
          SizedBox(height: Sizes.medium),
          Text(
            'Tidak ada transaksi',
            style: TahuraTextStyles.screenTitle,
          )
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideY(begin: 0.2, end: 0),
          Text(
            'Belum ada transaksi yang tercatat',
            style: TahuraTextStyles.bodyText,
          )
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<Map<String, dynamic>> filteredTransactions) {
    final totalAmount = filteredTransactions.fold<double>(
      0,
      (sum, transaction) => sum + (transaction['amount'] ?? 0),
    );

    return Container(
      margin: EdgeInsets.all(Sizes.medium),
      padding: EdgeInsets.all(Sizes.medium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        boxShadow: TahuraShadows.medium,
      ),
      child: Column(
        children: [
          Text(
            DateFormat('dd MMMM yyyy').format(_selectedDate),
            style: TahuraTextStyles.screenTitle,
          ),
          SizedBox(height: Sizes.small),
          Text(
            'Total Pendapatan',
            style: TahuraTextStyles.bodyText,
          ),
          Text(
            currencyFormat.format(totalAmount),
            style: TahuraTextStyles.screenTitle.copyWith(
              color: TahuraColors.success,
            ),
          ),
          SizedBox(height: Sizes.small),
          Text(
            '${filteredTransactions.length} Transaksi',
            style: TahuraTextStyles.bodyText,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: TahuraAnimations.medium)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildTransactionsList(
      List<Map<String, dynamic>> filteredTransactions) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: Sizes.medium),
      itemCount: filteredTransactions.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return _buildTransactionCard(transaction, index);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: Sizes.medium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
      ),
      color: Colors.white.withOpacity(0.2),
      child: ListTile(
        contentPadding: EdgeInsets.all(Sizes.medium),
        title: Text(
          transaction['product_name'] ?? 'Unknown Product',
          style: TahuraTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Sizes.small),
            Text(
              'User: ${transaction['user_name'] ?? 'Unknown User'}',
              style: TahuraTextStyles.bodyText,
            ),
            Text(
              DateFormat('HH:mm')
                  .format(DateTime.parse(transaction['transaction_date'])),
              style: TahuraTextStyles.bodyText,
            ),
          ],
        ),
        trailing: Text(
          currencyFormat.format(transaction['amount'] ?? 0),
          style: TahuraTextStyles.bodyText.copyWith(
            color: TahuraColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: TahuraAnimations.medium,
          delay: Duration(milliseconds: 50 * index),
        )
        .slideX(begin: 0.2, end: 0);
  }
}
