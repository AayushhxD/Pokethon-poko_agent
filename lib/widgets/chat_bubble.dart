import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final Color agentColor;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.agentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 20),
          ),
          border:
              isUser
                  ? null
                  : Border.all(color: agentColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color:
                  isUser
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
