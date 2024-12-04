import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditPriceScreen extends StatefulWidget {
  @override
  _EditPriceScreenState createState() => _EditPriceScreenState();
}

class _EditPriceScreenState extends State<EditPriceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adultTicketController = TextEditingController();
  final _childTicketController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _isProcessing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPrices();
    _adultTicketController.addListener(_onFieldChanged);
    _childTicketController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _loadCurrentPrices() async {
    try {
      final prices = await _dbHelper.getLatestTicketPrices();
      if (prices != null) {
        setState(() {
          _adultTicketController.text =
              prices['adult_price'].toStringAsFixed(0);
          _childTicketController.text =
              prices['child_price'].toStringAsFixed(0);
        });
      }
    } catch (e) {
      _showError('Failed to load current prices');
    }
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

  Future<void> _saveprices() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final adultPrice = double.parse(_adultTicketController.text);
      final childPrice = double.parse(_childTicketController.text);

      await _dbHelper.updateTicketPrices(adultPrice, childPrice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Prices updated successfully!',
              style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
            ),
            backgroundColor: TahuraColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(Sizes.medium),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Failed to update prices');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Discard Changes?',
            style: TahuraTextStyles.screenTitle.copyWith(color: Colors.black),
          ),
          content: Text(
            'You have unsaved changes. Are you sure you want to discard them?',
            style: TahuraTextStyles.bodyText.copyWith(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Stay',
                style: TahuraTextStyles.bodyText.copyWith(
                  color: TahuraColors.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Discard',
                style: TahuraTextStyles.bodyText.copyWith(
                  color: TahuraColors.error,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return true;
  }

  @override
  void dispose() {
    _adultTicketController.dispose();
    _childTicketController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Edit Ticket Prices',
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriceField(
                      controller: _adultTicketController,
                      label: 'Adult Ticket Price',
                      icon: Icons.person,
                    )
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.2, end: 0),
                    SizedBox(height: Sizes.medium),
                    _buildPriceField(
                      controller: _childTicketController,
                      label: 'Child Ticket Price',
                      icon: Icons.child_care,
                    )
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.3, end: 0),
                    SizedBox(height: Sizes.large),
                    _buildSaveButton()
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.4, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TahuraTextStyles.bodyText,
        ),
        SizedBox(height: Sizes.small),
        TextFormField(
          controller: controller,
          decoration: TahuraInputDecorations.defaultInput.copyWith(
            prefixIcon: Icon(icon, color: TahuraColors.primary),
            prefixText: 'Rp ',
          ),
          style: TahuraTextStyles.bodyText.copyWith(color: Colors.black),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a price';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (double.parse(value) <= 0) {
              return 'Price must be greater than 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: Sizes.buttonHeight,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _saveprices,
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
                'Save Changes',
                style: TahuraTextStyles.buttonText,
              ),
      ),
    );
  }
}
