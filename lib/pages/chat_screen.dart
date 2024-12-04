import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:myapp/edit_faq_screen.dart';
import 'package:myapp/models/message.dart';
import 'package:myapp/models/message.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:myapp/database_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class ChatScreen extends StatefulWidget {
  final bool isAdminOrStaff;

  const ChatScreen({Key? key, required this.isAdminOrStaff}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userMessage = TextEditingController();
  bool isLoading = false;
  bool isFAQMode = true;
  bool isTyping = false;

  static const apiKey = "AIzaSyC77cRt4Wvl9MFe98AsQqzKpiJkMCkxscA";
  final List<Message> _messages = [];
  late GenerativeModel model;

  List<Map<String, dynamic>> faqList = [
    {
      'question': 'Apa itu Tahura Bandung?',
      'answer':
          'Tahura Bandung (Taman Hutan Raya) adalah kawasan hutan lindung yang terletak di Bandung, Jawa Barat. Merupakan area konservasi dengan keanekaragaman hayati yang tinggi.'
    },
    {
      'question': 'Destinasi apa saja yang ada di Tahura?',
      'answer':
          'Beberapa destinasi di Tahura Bandung meliputi: Kebun Raya Bandung, Jalur Pendakian, Area Perkemahan, Hutan Pinus, dan Spot Fotografi Alam.'
    },
    // ... rest of the FAQ list remains the same ...
  ];

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    _loadFAQs();
  }

  Future<void> _loadFAQs() async {
    try {
      final faqs = await DatabaseHelper().getAllFAQs();
      setState(() {
        faqList = [
          ...faqList,
          ...faqs.map((faq) => {
                'id': faq['id'].toString(),
                'question': faq['question'],
                'answer': faq['answer']
              }),
        ];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load FAQs. Please try again.',
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

  Future<void> sendMessage() async {
    final message = _userMessage.text;
    _userMessage.clear();

    setState(() {
      _messages.add(Message(
        isUser: true,
        message: message,
        date: DateTime.now(),
      ));
      isLoading = true;
      isTyping = true;
    });

    const context = '''
    Kamu adalah asisten AI untuk Aplikasi Tahura Bandung. 
    Fokus pada informasi seputar:
    - Lokasi Tahura
    - Destinasi di Tahura
    - Kondisi alam
    - Aktivitas di kawasan
    ''';

    final content = [Content.text('$context\n\nPertanyaan: $message')];

    try {
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(
          isUser: false,
          message: response.text ?? "Maaf, saya tidak mengerti.",
          date: DateTime.now(),
        ));
        isLoading = false;
        isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
          isUser: false,
          message: "Terjadi kesalahan. Coba lagi.",
          date: DateTime.now(),
        ));
        isLoading = false;
        isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: isFAQMode ? _buildFAQList() : _buildChatInterface(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        isFAQMode ? 'FAQ Tahura' : 'Chat AI Tahura',
        style: TahuraTextStyles.appBarTitle,
      )
          .animate()
          .fadeIn(duration: TahuraAnimations.medium)
          .slideX(begin: -0.2, end: 0),
      actions: [
        IconButton(
          icon: Icon(
            isFAQMode ? Icons.chat : Icons.list,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              isFAQMode = !isFAQMode;
            });
          },
        ).animate().fadeIn(duration: TahuraAnimations.medium),
        if (isFAQMode && widget.isAdminOrStaff)
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _addFAQ,
          ).animate().fadeIn(duration: TahuraAnimations.medium),
      ],
    );
  }

  Widget _buildFAQList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(Sizes.medium),
      itemCount: faqList.length,
      itemBuilder: (context, index) {
        final faq = faqList[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: Sizes.medium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radiusMedium),
          ),
          child: ExpansionTile(
            title: Text(
              faq['question']!,
              style: TahuraTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.w600,
                color: TahuraColors.primary,
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(Sizes.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq['answer']!,
                      style: TahuraTextStyles.bodyText.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    if (widget.isAdminOrStaff) ...[
                      SizedBox(height: Sizes.medium),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _editFAQ(index),
                            icon: Icon(Icons.edit),
                            label: Text('Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: TahuraColors.primary,
                            ),
                          ),
                          SizedBox(width: Sizes.small),
                          TextButton.icon(
                            onPressed: () => _deleteFAQ(int.parse(faq['id']!)),
                            icon: Icon(Icons.delete),
                            label: Text('Delete'),
                            style: TextButton.styleFrom(
                              foregroundColor: TahuraColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(
              duration: TahuraAnimations.medium,
              delay: Duration(milliseconds: 50 * index),
            )
            .slideX(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: Sizes.medium,
              vertical: Sizes.small,
            ),
            itemCount: _messages.length + (isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (isTyping && index == 0) {
                return _buildTypingIndicator();
              }
              final message = _messages[isTyping ? index - 1 : index];
              return _buildMessageBubble(message)
                  .animate()
                  .fadeIn(duration: TahuraAnimations.medium)
                  .slideY(begin: 0.2, end: 0);
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: Sizes.small),
        padding: EdgeInsets.all(Sizes.small),
        decoration: BoxDecoration(
          color: Colors.grey[800]!.withOpacity(0.8),
          borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI is typing',
              style: TahuraTextStyles.bodyText,
            ),
            SizedBox(width: Sizes.small),
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: EdgeInsets.only(left: 2),
      child: Icon(
        Icons.circle,
        size: 4,
        color: Colors.white,
      )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .fadeOut(
            delay: Duration(milliseconds: 300 * index),
            duration: const Duration(milliseconds: 600),
          ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: Sizes.small),
        padding: EdgeInsets.all(Sizes.medium),
        decoration: BoxDecoration(
          color: message.isUser
              ? TahuraColors.primary.withOpacity(0.8)
              : Colors.grey[800]!.withOpacity(0.8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Sizes.radiusMedium),
            topRight: Radius.circular(Sizes.radiusMedium),
            bottomLeft: message.isUser
                ? Radius.circular(Sizes.radiusMedium)
                : Radius.circular(0),
            bottomRight: message.isUser
                ? Radius.circular(0)
                : Radius.circular(Sizes.radiusMedium),
          ),
          boxShadow: TahuraShadows.small,
        ),
        constraints: BoxConstraints(
          maxWidth: ScreenUtils.getResponsiveWidth(70),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TahuraTextStyles.bodyText,
            ),
            SizedBox(height: Sizes.xsmall),
            Text(
              DateFormat('HH:mm').format(message.date),
              style: TahuraTextStyles.bodyTextSecondary.copyWith(
                fontSize: Sizes.fontXSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(Sizes.medium),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        boxShadow: TahuraShadows.medium,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _userMessage,
              decoration: TahuraInputDecorations.defaultInput.copyWith(
                hintText: 'Tanya seputar Tahura...',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: isLoading
                    ? Container(
                        padding: EdgeInsets.all(Sizes.small),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : null,
              ),
              maxLines: null,
              onChanged: (value) => setState(() {}),
            ),
          ),
          SizedBox(width: Sizes.small),
          CircleAvatar(
            backgroundColor: TahuraColors.primary,
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed:
                  isLoading || _userMessage.text.isEmpty ? null : sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _addFAQ() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFAQScreen(
          onUpdate: (String question, String answer) async {
            await DatabaseHelper().insertFAQ(question, answer);
            _loadFAQs();
          },
        ),
      ),
    );
  }

  void _editFAQ(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFAQScreen(
          question: faqList[index]['question'],
          answer: faqList[index]['answer'],
          onUpdate: (String question, String answer) async {
            await DatabaseHelper().deleteFAQ(int.parse(faqList[index]['id']!));
            await DatabaseHelper().insertFAQ(question, answer);
            _loadFAQs();
          },
        ),
      ),
    );
  }

  void _deleteFAQ(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Delete',
          style: TahuraTextStyles.screenTitle.copyWith(color: Colors.black),
        ),
        content: Text(
          'Are you sure you want to delete this FAQ?',
          style: TahuraTextStyles.bodyText.copyWith(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TahuraTextStyles.bodyText.copyWith(
                color: TahuraColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: TahuraColors.error,
            ),
            child: Text(
              'Delete',
              style: TahuraTextStyles.bodyText,
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await DatabaseHelper().deleteFAQ(id);
      _loadFAQs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'FAQ deleted successfully',
              style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
            ),
            backgroundColor: TahuraColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(Sizes.medium),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _userMessage.dispose();
    super.dispose();
  }
}
