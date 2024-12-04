import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/size.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:myapp/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';

class TicketScreen extends StatefulWidget {
  const TicketScreen({Key? key}) : super(key: key);

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with SingleTickerProviderStateMixin {
  int _adultTickets = 0;
  int _childTickets = 0;
  double _ticketPrice = 50000;
  double _childTicketPrice = 25000;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final dbHelper = DatabaseHelper();
    try {
      final transactions = await dbHelper.getAllTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching transactions: $e');
      setState(() {
        _isLoading = false;
      });

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

  double _calculateTotal() {
    return (_adultTickets * _ticketPrice) + (_childTickets * _childTicketPrice);
  }

  void _incrementTicket(bool isAdult) {
    setState(() {
      if (isAdult) {
        _adultTickets++;
      } else {
        _childTickets++;
      }
    });
  }

  void _decrementTicket(bool isAdult) {
    setState(() {
      if (isAdult) {
        if (_adultTickets > 0) _adultTickets--;
      } else {
        if (_childTickets > 0) _childTickets--;
      }
    });
  }

  Future<void> _saveTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    final dbHelper = DatabaseHelper();
    await dbHelper.insertDetailedTransaction(
      paymentMethod: 'Tiket Masuk',
      amount: _calculateTotal(),
      productName: 'Tiket Perjalanan',
      userName: userEmail ?? 'Tidak Diketahui',
      adultTickets: _adultTickets,
      childTickets: _childTickets,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: TahuraColors.primary,
          title: Text(
            'Tiket Tahura',
            style: TahuraTextStyles.appBarTitle,
          )
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideX(begin: -0.2, end: 0),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Text(
                  'Beli Tiket',
                  style: TahuraTextStyles.bodyText,
                ).animate().fadeIn(duration: TahuraAnimations.medium),
              ),
              Tab(
                child: Text(
                  'Tiket Saya',
                  style: TahuraTextStyles.bodyText,
                ).animate().fadeIn(duration: TahuraAnimations.medium),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/screen.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTicketPurchaseTab(),
              _buildMyTicketTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketPurchaseTab() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(Sizes.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTicketTypeCard(
              title: 'Tiket Dengan Pemandu',
              price: _ticketPrice,
              count: _adultTickets,
              isAdult: true,
            )
                .animate()
                .fadeIn(duration: TahuraAnimations.medium)
                .slideX(begin: -0.2, end: 0),
            SizedBox(height: Sizes.medium),
            _buildTicketTypeCard(
              title: 'Tiket Masuk',
              price: _childTicketPrice,
              count: _childTickets,
              isAdult: false,
            )
                .animate()
                .fadeIn(duration: TahuraAnimations.medium)
                .slideX(begin: 0.2, end: 0),
            SizedBox(height: Sizes.large),
            _buildTotalSection()
                .animate()
                .fadeIn(duration: TahuraAnimations.medium)
                .slideY(begin: 0.2, end: 0),
            SizedBox(height: Sizes.large),
            _buildPaymentButton()
                .animate()
                .fadeIn(duration: TahuraAnimations.medium)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketTypeCard({
    required String title,
    required double price,
    required int count,
    required bool isAdult,
  }) {
    return Container(
      padding: EdgeInsets.all(Sizes.medium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        boxShadow: TahuraShadows.medium,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TahuraTextStyles.screenTitle,
          ),
          SizedBox(height: Sizes.small),
          Text(
            'Rp ${price.toStringAsFixed(0)}',
            style: TahuraTextStyles.bodyText,
          ),
          SizedBox(height: Sizes.medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.white,
                  size: Sizes.iconLarge,
                ),
                onPressed: () => _decrementTicket(isAdult),
              ),
              SizedBox(width: Sizes.medium),
              Text(
                count.toString(),
                style: TahuraTextStyles.screenTitle,
              ),
              SizedBox(width: Sizes.medium),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: Sizes.iconLarge,
                ),
                onPressed: () => _incrementTicket(isAdult),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: EdgeInsets.all(Sizes.medium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        boxShadow: TahuraShadows.medium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Harga',
            style: TahuraTextStyles.screenTitle,
          ),
          Text(
            'Rp ${_calculateTotal().toStringAsFixed(0)}',
            style: TahuraTextStyles.screenTitle,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: Sizes.buttonHeight,
      child: ElevatedButton(
        onPressed: _adultTickets + _childTickets > 0
            ? () {
                _saveTransaction();
                Navigator.pushNamed(
                  context,
                  '/payment',
                  arguments: {
                    'adultTickets': _adultTickets,
                    'childTickets': _childTickets,
                    'totalPrice': _calculateTotal(),
                  },
                );
              }
            : null,
        style: TahuraButtons.primaryButton,
        child: Text(
          'Lanjut Pembayaran',
          style: TahuraTextStyles.buttonText,
        ),
      ),
    );
  }

  Widget _buildMyTicketTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: TahuraColors.primary,
        ),
      );
    }

    if (_transactions.isEmpty) {
      return _buildNoTicketMessage();
    }

    final lastTransaction = _transactions.first;
    return Container(
      color: Colors.white,
      child: Center(
        child: _buildTicketQRCode(lastTransaction),
      ),
    );
  }

  Widget _buildNoTicketMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.confirmation_number_outlined,
          size: Sizes.iconXLarge * 2,
          color: Colors.white54,
        ).animate().fadeIn(duration: TahuraAnimations.medium).scale(),
        SizedBox(height: Sizes.large),
        Text(
          'Belum Ada Tiket',
          style: TahuraTextStyles.screenTitle,
        )
            .animate()
            .fadeIn(duration: TahuraAnimations.medium)
            .slideY(begin: 0.2, end: 0),
        Text(
          'Silakan beli tiket terlebih dahulu',
          style: TahuraTextStyles.bodyText,
        )
            .animate()
            .fadeIn(duration: TahuraAnimations.medium)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildTicketQRCode(Map<String, dynamic> transaction) {
    Map<String, dynamic> transactionData = {};

    try {
      transactionData = jsonDecode(transaction['product_name'] ?? '{}');
    } catch (e) {
      transactionData = {
        'payment_method': transaction['payment_method'] ?? 'Tidak Diketahui',
        'total_price': transaction['amount'] ?? 0.0,
        'transaction_date':
            transaction['transaction_date'] ?? DateTime.now().toIso8601String(),
        'product_name': transaction['product_name'] ?? 'Tiket Perjalanan',
      };
    }

    return Padding(
      padding: EdgeInsets.all(Sizes.large),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.radiusLarge),
            ),
            child: Padding(
              padding: EdgeInsets.all(Sizes.medium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QrImageView(
                    data: jsonEncode(transactionData),
                    version: QrVersions.auto,
                    size: ScreenUtils.getResponsiveWidth(60),
                  ).animate().fadeIn(duration: TahuraAnimations.medium).scale(),
                  SizedBox(height: Sizes.large),
                  Text(
                    'Produk: ${transactionData['product_name'] ?? 'Tiket'}',
                    style: TahuraTextStyles.screenTitle.copyWith(
                      color: Colors.black,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: TahuraAnimations.medium)
                      .slideY(begin: 0.2, end: 0),
                  SizedBox(height: Sizes.medium),
                  Text(
                    'Total Bayar: Rp ${(transactionData['total_price'] ?? 0.0).toStringAsFixed(0)}',
                    style: TahuraTextStyles.bodyText.copyWith(
                      color: Colors.black87,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: TahuraAnimations.medium)
                      .slideY(begin: 0.3, end: 0),
                  Text(
                    'Metode Bayar: ${transactionData['payment_method'] ?? 'Tidak Diketahui'}',
                    style: TahuraTextStyles.bodyText.copyWith(
                      color: Colors.black54,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: TahuraAnimations.medium)
                      .slideY(begin: 0.4, end: 0),
                  Text(
                    'Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(transactionData['transaction_date'] ?? DateTime.now().toIso8601String()))}',
                    style: TahuraTextStyles.bodyText.copyWith(
                      color: Colors.black54,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: TahuraAnimations.medium)
                      .slideY(begin: 0.5, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
