import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/size.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:myapp/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransactionScreen extends StatefulWidget {
  final double totalPrice;
  const TransactionScreen({Key? key, required this.totalPrice})
      : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String? _paymentMethod;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Transaksi Pembayaran',
          style: TahuraTextStyles.appBarTitle,
        )
            .animate()
            .fadeIn(duration: TahuraAnimations.medium)
            .slideX(begin: -0.2, end: 0),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(Sizes.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPaymentMethodSelection()
                    .animate()
                    .fadeIn(duration: TahuraAnimations.medium)
                    .slideY(begin: 0.2, end: 0),
                if (_paymentMethod != null)
                  _buildPaymentInput()
                      .animate()
                      .fadeIn(duration: TahuraAnimations.medium)
                      .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Metode Pembayaran',
          style: TahuraTextStyles.screenTitle,
        ),
        SizedBox(height: Sizes.medium),
        _buildPaymentMethodCard(
          'Debit',
          'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/card.png',
          'debit',
        ),
        SizedBox(height: Sizes.medium),
        _buildPaymentMethodCard(
          'E-Wallet',
          'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/e-wallet.png',
          'e-wallet',
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
      String title, String imagePath, String method) {
    bool isSelected = _paymentMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(Sizes.radiusMedium),
      child: Container(
        padding: EdgeInsets.all(Sizes.medium),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(Sizes.radiusMedium),
          border: Border.all(
            color: isSelected ? TahuraColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? TahuraShadows.medium : null,
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: Sizes.iconXLarge,
              height: Sizes.iconXLarge,
            ),
            SizedBox(width: Sizes.medium),
            Text(
              title,
              style: TahuraTextStyles.bodyText.copyWith(
                color: isSelected ? TahuraColors.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: TahuraColors.primary,
                size: Sizes.iconMedium,
              ),
          ],
        ),
      ),
    )
.animate(target: isSelected ? 1 : 0)
.scale(begin: Offset(1, 1), end: Offset(1.02, 1.02))
.tint(color: Colors.white.withOpacity(0.1));
  }

  Widget _buildPaymentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Sizes.large),
        Text(
          _paymentMethod == 'debit' ? 'Informasi Kartu' : 'Informasi E-Wallet',
          style: TahuraTextStyles.screenTitle,
        ),
        SizedBox(height: Sizes.medium),
        _paymentMethod == 'debit'
            ? _buildCardPaymentInput()
            : _buildEWalletInput(),
      ],
    );
  }

  Widget _buildCardPaymentInput() {
    return Column(
      children: [
        TextFormField(
          controller: _cardNumberController,
          decoration: TahuraInputDecorations.defaultInput.copyWith(
            labelText: 'Nomor Kartu (16 digit)',
            prefixIcon: Icon(Icons.credit_card, color: TahuraColors.primary),
          ),
          keyboardType: TextInputType.number,
          maxLength: 16,
        ),
        SizedBox(height: Sizes.medium),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryDateController,
                decoration: TahuraInputDecorations.defaultInput.copyWith(
                  labelText: 'Expiry Date (MM/YY)',
                  prefixIcon:
                      Icon(Icons.calendar_today, color: TahuraColors.primary),
                ),
                keyboardType: TextInputType.datetime,
                maxLength: 5,
              ),
            ),
            SizedBox(width: Sizes.medium),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: TahuraInputDecorations.defaultInput.copyWith(
                  labelText: 'CVV',
                  prefixIcon: Icon(Icons.lock, color: TahuraColors.primary),
                ),
                keyboardType: TextInputType.number,
                maxLength: 3,
                obscureText: true,
              ),
            ),
          ],
        ),
        SizedBox(height: Sizes.large),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildEWalletInput() {
    return Column(
      children: [
        TextFormField(
          controller: _phoneNumberController,
          decoration: TahuraInputDecorations.defaultInput.copyWith(
            labelText: 'Nomor Telepon',
            prefixIcon: Icon(Icons.phone, color: TahuraColors.primary),
            prefixText: '+62 ',
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            setState(() {});
          },
        ),
        SizedBox(height: Sizes.large),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: Sizes.buttonHeight,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _submitOrder,
        style: TahuraButtons.primaryButton,
        child: _isProcessing
            ? SizedBox(
                height: Sizes.iconMedium,
                width: Sizes.iconMedium,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Bayar Rp ${widget.totalPrice.toStringAsFixed(0)}',
                style: TahuraTextStyles.buttonText,
              ),
      ),
    );
  }

  bool _validateInputs() {
    if (_paymentMethod == 'debit') {
      if (_cardNumberController.text.length != 16) {
        _showError('Nomor kartu harus 16 digit');
        return false;
      }
      if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(_expiryDateController.text)) {
        _showError('Format tanggal kadaluarsa harus MM/YY');
        return false;
      }
      if (_cvvController.text.length != 3) {
        _showError('CVV harus 3 digit');
        return false;
      }
    } else {
      if (_phoneNumberController.text.length < 10) {
        _showError('Nomor telepon tidak valid');
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
        ),
        backgroundColor: TahuraColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(Sizes.medium),
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (!_validateInputs()) return;

    setState(() => _isProcessing = true);

    try {
      await _saveTransaction();

      if (mounted) {
        _showPaymentSuccess();
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal memproses pembayaran. Silakan coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _saveTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    final dbHelper = DatabaseHelper();
    await dbHelper.insertDetailedTransaction(
      paymentMethod: _paymentMethod ?? 'Tidak Diketahui',
      amount: widget.totalPrice,
      productName: 'Tiket Perjalanan',
      userName: userEmail ?? 'Tidak Diketahui',
    );
  }

  void _showPaymentSuccess() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Sizes.radiusLarge),
        ),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(Sizes.large),
        height: ScreenUtils.getResponsiveHeight(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: TahuraColors.success,
              size: Sizes.iconXLarge * 2,
            ).animate().fadeIn(duration: TahuraAnimations.medium).scale(),
            SizedBox(height: Sizes.large),
            Text(
              'Pembayaran Berhasil',
              style: TahuraTextStyles.screenTitle.copyWith(
                color: Colors.black,
              ),
            )
                .animate()
                .fadeIn(duration: TahuraAnimations.medium)
                .slideY(begin: 0.2, end: 0),
            SizedBox(height: Sizes.large),
            QrImageView(
              data: 'Transaksi: ${DateTime.now().toIso8601String()}',
              version: QrVersions.auto,
              size: ScreenUtils.getResponsiveWidth(50),
            ).animate().fadeIn(duration: TahuraAnimations.medium).scale(),
            SizedBox(height: Sizes.large),
            Text(
              'Total Pembayaran: Rp ${widget.totalPrice.toStringAsFixed(0)}',
              style: TahuraTextStyles.bodyText.copyWith(
                color: Colors.black87,
              ),
            )
                .animate()
                .fadeIn(duration: TahuraAnimations.medium)
                .slideY(begin: 0.3, end: 0),
            SizedBox(height: Sizes.large),
            SizedBox(
              width: double.infinity,
              height: Sizes.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: TahuraButtons.primaryButton,
                child: Text(
                  'Selesai',
                  style: TahuraTextStyles.buttonText,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: TahuraAnimations.medium)
                .slideY(begin: 0.4, end: 0),
          ],
        ),
      ),
    );
  }
}
