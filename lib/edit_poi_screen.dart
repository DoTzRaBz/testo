import 'package:flutter/material.dart';
import 'package:myapp/models/POI.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditPOIScreen extends StatefulWidget {
  final PointOfInterest poi;

  const EditPOIScreen({Key? key, required this.poi}) : super(key: key);

  @override
  _EditPOIScreenState createState() => _EditPOIScreenState();
}

class _EditPOIScreenState extends State<EditPOIScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  bool _isProcessing = false;
  File? _imageFile;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.poi.name);
    _descriptionController =
        TextEditingController(text: widget.poi.description);
    _latitudeController =
        TextEditingController(text: widget.poi.latitude.toString());
    _longitudeController =
        TextEditingController(text: widget.poi.longitude.toString());

    // Listen for changes
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _latitudeController.addListener(_onFieldChanged);
    _longitudeController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to pick image. Please try again.',
            style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
          ),
          backgroundColor: TahuraColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(Sizes.medium),
        ),
      );
    }
  }

  Future<void> _savePOI() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final latitude = double.parse(_latitudeController.text);
      final longitude = double.parse(_longitudeController.text);

      await DatabaseHelper().updatePOI(
        widget.poi.id,
        _nameController.text,
        _descriptionController.text,
        latitude,
        longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'POI successfully updated!',
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update POI. Please try again.',
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
        setState(() => _isProcessing = false);
      }
    }
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
            'Edit Point of Interest',
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
                    _buildImageSection()
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .scale(),
                    SizedBox(height: Sizes.large),
                    _buildTextField(
                      controller: _nameController,
                      label: 'POI Name',
                      icon: Icons.place,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter POI name';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.2, end: 0),
                    SizedBox(height: Sizes.medium),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.3, end: 0),
                    SizedBox(height: Sizes.medium),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _latitudeController,
                            label: 'Latitude',
                            icon: Icons.explore,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: Sizes.medium),
                        Expanded(
                          child: _buildTextField(
                            controller: _longitudeController,
                            label: 'Longitude',
                            icon: Icons.explore,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.4, end: 0),
                    SizedBox(height: Sizes.large),
                    _buildSaveButton()
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.5, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: ScreenUtils.getResponsiveHeight(25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(Sizes.radiusMedium),
          image: DecorationImage(
            image: _imageFile != null
                ? FileImage(_imageFile!) as ImageProvider
                : AssetImage(widget.poi.imageUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: TahuraShadows.medium,
        ),
        child: Center(
          child: Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: Sizes.iconXLarge,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: TahuraInputDecorations.defaultInput.copyWith(
        labelText: label,
        prefixIcon: Icon(icon, color: TahuraColors.primary),
      ),
      style: TahuraTextStyles.bodyText.copyWith(color: Colors.black),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: Sizes.buttonHeight,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _savePOI,
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
