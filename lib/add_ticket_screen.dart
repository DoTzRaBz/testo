import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddTicketScreen extends StatefulWidget {
  @override
  _AddTicketScreenState createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxUsageController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _isProcessing = false;
  bool _hasChanges = false;
  DateTime? _validUntil;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _maxUsageController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

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

  Future<void> _selectValidityDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
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
        _validUntil = picked;
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveNewTicketPackage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_validUntil == null) {
      _showError('Please select package validity date');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final price = double.parse(_priceController.text);
      final maxUsage = int.tryParse(_maxUsageController.text);

      await _dbHelper.insertTicketPackage(
        name: _nameController.text,
        price: price,
        description: _descriptionController.text,
        maxUsage: maxUsage,
        validUntil: _validUntil!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'New ticket package successfully added!',
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
      _showError('Failed to save ticket package. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _maxUsageController.dispose();
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
            'Add New Ticket Package',
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
                    _buildTextField(
                      controller: _nameController,
                      label: 'Package Name',
                      icon: Icons.card_membership,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter package name';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.2, end: 0),
                    SizedBox(height: Sizes.medium),
                    _buildTextField(
                      controller: _priceController,
                      label: 'Package Price',
                      icon: Icons.attach_money,
                      prefixText: 'Rp ',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter package price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.3, end: 0),
                    SizedBox(height: Sizes.medium),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Package Description',
                      icon: Icons.description,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter package description';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.4, end: 0),
                    SizedBox(height: Sizes.medium),
                    _buildTextField(
                      controller: _maxUsageController,
                      label: 'Maximum Usage (Optional)',
                      icon: Icons.repeat,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.5, end: 0),
                    SizedBox(height: Sizes.medium),
                    _buildValidityDateSection()
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.6, end: 0),
                    SizedBox(height: Sizes.large),
                    _buildSaveButton()
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.7, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefixText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
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
            prefixText: prefixText,
          ),
          style: TahuraTextStyles.bodyText.copyWith(color: Colors.black),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildValidityDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Package Validity',
          style: TahuraTextStyles.bodyText,
        ),
        SizedBox(height: Sizes.small),
        InkWell(
          onTap: _selectValidityDate,
          child: Container(
            padding: EdgeInsets.all(Sizes.medium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Sizes.radiusMedium),
              border: Border.all(
                color: TahuraColors.primary.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: TahuraColors.primary),
                SizedBox(width: Sizes.medium),
                Text(
                  _validUntil != null
                      ? 'Valid until: ${_validUntil!.day}/${_validUntil!.month}/${_validUntil!.year}'
                      : 'Select validity date',
                  style:
                      TahuraTextStyles.bodyText.copyWith(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: Sizes.buttonHeight,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _saveNewTicketPackage,
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
                'Save Package',
                style: TahuraTextStyles.buttonText,
              ),
      ),
    );
  }
}
