import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditFAQScreen extends StatefulWidget {
  final String? question;
  final String? answer;
  final Function(String, String) onUpdate;

  const EditFAQScreen({
    Key? key,
    this.question,
    this.answer,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditFAQScreenState createState() => _EditFAQScreenState();
}

class _EditFAQScreenState extends State<EditFAQScreen> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question);
    _answerController = TextEditingController(text: widget.answer);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      widget.onUpdate(_questionController.text, _answerController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'FAQ successfully saved!',
              style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
            ),
            backgroundColor: TahuraColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(Sizes.medium),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save FAQ. Please try again.',
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

  Future<bool> _onWillPop() async {
    if (_questionController.text.isNotEmpty ||
        _answerController.text.isNotEmpty) {
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.question != null ? 'Edit FAQ' : 'Add New FAQ',
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
                    _buildQuestionField()
                        .animate()
                        .fadeIn(duration: TahuraAnimations.medium)
                        .slideY(begin: 0.2, end: 0),
                    SizedBox(height: Sizes.medium),
                    _buildAnswerField()
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

  Widget _buildQuestionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question',
          style: TahuraTextStyles.bodyText,
        ),
        SizedBox(height: Sizes.small),
        TextFormField(
          controller: _questionController,
          decoration: TahuraInputDecorations.defaultInput.copyWith(
            hintText: 'Enter your question here',
            prefixIcon: Icon(Icons.help_outline, color: TahuraColors.primary),
          ),
          style: TahuraTextStyles.bodyText.copyWith(color: Colors.black),
          maxLines: null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a question';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAnswerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Answer',
          style: TahuraTextStyles.bodyText,
        ),
        SizedBox(height: Sizes.small),
        TextFormField(
          controller: _answerController,
          decoration: TahuraInputDecorations.defaultInput.copyWith(
            hintText: 'Enter your answer here',
            prefixIcon: Icon(Icons.edit_note, color: TahuraColors.primary),
            alignLabelWithHint: true,
          ),
          style: TahuraTextStyles.bodyText.copyWith(color: Colors.black),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an answer';
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
        onPressed: _isProcessing ? null : _saveChanges,
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
                'Save FAQ',
                style: TahuraTextStyles.buttonText,
              ),
      ),
    );
  }
}
