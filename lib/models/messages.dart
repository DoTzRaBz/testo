import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  final Function onAnimatedTextFinished;
  final isAnimated = ValueNotifier(false);

  Messages({
    Key? key,
    required this.isUser,
    required this.message,
    required this.date,
    required this.onAnimatedTextFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Sizes.small),
      margin: EdgeInsets.symmetric(vertical: Sizes.small).copyWith(
        left: isUser ? ScreenUtils.getResponsiveWidth(30) : Sizes.xsmall,
        right: isUser ? Sizes.xsmall : ScreenUtils.getResponsiveWidth(30),
      ),
      decoration: BoxDecoration(
        color: isUser ? TahuraColors.userChat : TahuraColors.resChat,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Sizes.radiusSmall),
          bottomLeft: isUser ? Radius.circular(Sizes.radiusSmall) : Radius.zero,
          topRight: Radius.circular(Sizes.radiusSmall),
          bottomRight:
              !isUser ? Radius.circular(Sizes.radiusSmall) : Radius.zero,
        ),
        boxShadow: TahuraShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            GestureDetector(
              onLongPress: () async {
                await Clipboard.setData(ClipboardData(text: message));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Message copied to clipboard',
                        style: TahuraTextStyles.bodyText,
                      ),
                      backgroundColor: TahuraColors.success,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(Sizes.medium),
                    ),
                  );
                }
              },
              child: Text(
                message,
                style: TahuraTextStyles.messageText,
              )
                  .animate()
                  .fadeIn(duration: TahuraAnimations.medium)
                  .slideX(begin: -0.2, end: 0),
            ),
          if (isUser)
            Text(
              message,
              style: TahuraTextStyles.messageText,
            )
                .animate()
                .fadeIn(duration: TahuraAnimations.medium)
                .slideX(begin: 0.2, end: 0),
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(
                "\n$date",
                style: TahuraTextStyles.dateText,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: TahuraAnimations.medium).scale();
  }
}
