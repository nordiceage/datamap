// import 'package:flutter/material.dart';
// import 'dart:ui';
// import 'package:intl/intl.dart';
// import 'package:material_symbols_icons/symbols.dart';
//
// import 'chat_message.dart';
//
// class ChatUI extends StatelessWidget {
//   final List<ChatMessage> messages;
//   final TextEditingController textController;
//   final ScrollController scrollController;
//   final bool isLoading;
//   final bool showLimitMessage;
//   final int chatLimit;
//   final Function(String) onSendMessage;
//   final VoidCallback onLimitReached;
//   final List<String> faqs;
//   final bool hideHistory;
//
//   const ChatUI({
//     Key? key,
//     required this.messages,
//     required this.textController,
//     required this.scrollController,
//     required this.isLoading,
//     required this.showLimitMessage,
//     required this.chatLimit,
//     required this.onSendMessage,
//     required this.onLimitReached,
//     required this.faqs,
//     required this.hideHistory,
//   }) : super(key: key);
//
//   String _getMessageDate(DateTime timestamp) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
//
//     if (messageDate == today) {
//       return 'Today';
//     } else if (messageDate == yesterday) {
//       return 'Yesterday';
//     } else {
//       return DateFormat('MMMM d, y').format(messageDate);
//     }
//   }
//
//   Widget _buildDateSeparator(String date) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 16),
//       child: Row(
//         children: [
//           Expanded(child: Divider(color: Colors.grey[300])),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 8),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 date,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(child: Divider(color: Colors.grey[300])),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageBubble(ChatMessage message, BuildContext context) {
//     final timeString = DateFormat('HH:mm').format(message.timestamp);
//
//     return Align(
//       alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.7,
//         ),
//         margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         child: Container(
//           decoration: BoxDecoration(
//             color: message.isUser
//                 ? Color(0xFFDCF8C6).withOpacity(0.95)
//                 : Colors.white.withOpacity(0.95),
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(message.isUser ? 15 : 0),
//               topRight: Radius.circular(message.isUser ? 0 : 15),
//               bottomLeft: Radius.circular(15),
//               bottomRight: Radius.circular(15),
//             ),
//             boxShadow: [
//               // Outer shadow
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 4,
//                 offset: Offset(0, 2),
//               ),
//               // Inner shadow
//               BoxShadow(
//                 color: Colors.white.withOpacity(0.5),
//                 blurRadius: 4,
//                 spreadRadius: -1,
//                 offset: Offset(0, 1),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(15),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//               child: Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.2),
//                     width: 0.5,
//                   ),
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: message.isUser
//                         ? [
//                       Color(0xFFDCF8C6).withOpacity(0.9),
//                       Color(0xFFDCF8C6).withOpacity(0.7),
//                     ]
//                         : [
//                       Colors.white.withOpacity(0.9),
//                       Colors.white.withOpacity(0.7),
//                     ],
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       message.content,
//                       style: TextStyle(
//                         color: Colors.black.withOpacity(0.9),
//                         fontSize: 14,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       timeString,
//                       style: TextStyle(
//                         color: Colors.black54,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTypingIndicator() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: EdgeInsets.only(left: 16, bottom: 16),
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: List.generate(3, (index) => _buildDot(index)),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDot(int index) {
//     return TweenAnimationBuilder(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: Duration(milliseconds: 800),
//       curve: Curves.easeInOut,
//       builder: (context, double value, child) {
//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: 2),
//           height: 8,
//           width: 8,
//           decoration: BoxDecoration(
//             color: Color.lerp(
//               Colors.grey[300],
//               Colors.grey[600],
//               (value + index / 3) % 1,
//             ),
//             shape: BoxShape.circle,
//           ),
//         );
//       },
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     final groupedMessages = <String, List<ChatMessage>>{};
//     for (var message in messages) {
//       final date = _getMessageDate(message.timestamp);
//       if (!groupedMessages.containsKey(date)) {
//         groupedMessages[date] = [];
//       }
//       groupedMessages[date]!.add(message);
//     }
//
//     final sortedDates = groupedMessages.keys.toList()
//       ..sort((a, b) => b.compareTo(a));
//
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.8,
//       height: MediaQuery.of(context).size.height * 0.8,
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         // WhatsApp background pattern
//         color: Color(0xFFE5DDD5),
//         image: DecorationImage(
//           image: NetworkImage(
//               'https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png'
//           ),
//           repeat: ImageRepeat.repeat,
//           opacity: 0.1,
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           //Header......
//           // FAQs Section - Now always visible
//           Container(
//             padding: EdgeInsets.symmetric(vertical: 16),
//             margin: EdgeInsets.only(bottom: 8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.9),
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 4,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     "Quick Questions:",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green[700],
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Row(
//                     children: faqs.map((faq) => Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 4),
//                       child: ActionChip(
//                         label: Text(
//                           faq,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.green[800],
//                           ),
//                         ),
//                         backgroundColor: Colors.green[50],
//                         elevation: 0,
//                         shadowColor: Colors.transparent,
//                         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                         onPressed: (chatLimit > 0)
//                             ? () => onSendMessage(faq)
//                             : onLimitReached,
//                       ),
//                     )).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Chat Messages
//           Expanded(
//             child: Container(
//               margin: EdgeInsets.symmetric(vertical: 8),
//               child: ListView.builder(
//                 controller: scrollController,
//                 reverse: true,
//                 padding: EdgeInsets.all(8),
//                 itemCount: sortedDates.length,
//                 itemBuilder: (context, index) {
//                   final date = sortedDates[index];
//                   final messagesForDate = groupedMessages[date]!;
//                   return Column(
//                     children: [
//                       _buildDateSeparator(date),
//                       ...messagesForDate.map((message) =>
//                           _buildMessageBubble(message, context)
//                       ).toList().reversed,
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//
//           // Typing Indicator
//           if (isLoading) _buildTypingIndicator(),
//
//           // Input Section
//           Container(
//             margin: EdgeInsets.only(top: 8),
//             padding: EdgeInsets.symmetric(horizontal: 8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(25),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: textController,
//                     decoration: InputDecoration(
//                       hintText: 'Ask about plant care...',
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(horizontal: 16),
//                     ),
//                     enabled: chatLimit > 0,
//                     onSubmitted: (chatLimit > 0)
//                         ? (value) {
//                       if (value.isNotEmpty) {
//                         onSendMessage(value);
//                         textController.clear();
//                       }
//                     }
//                         : null,
//                   ),
//                 ),
//                 IconButton(
//                   // icon: Icon(Icons.send),
//                   icon: Icon(Symbols.keyboard_double_arrow_right),
//                   color: Colors.green,
//                   onPressed: (chatLimit > 0)
//                       ? () {
//                     final query = textController.text.trim();
//                     if (query.isNotEmpty) {
//                       onSendMessage(query);
//                       textController.clear();
//                     }
//                   }
//                       : onLimitReached,
//                 ),
//               ],
//             ),
//           ),
//
//           // Remaining Chats Counter
//           Padding(
//             padding: EdgeInsets.only(top: 8),
//             child: Text(
//               "Chats remaining: $chatLimit",
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'chat_message.dart';

class ChatUI extends StatelessWidget {
  final List<ChatMessage> messages;
  final TextEditingController textController;
  final ScrollController scrollController;
  final bool isLoading;
  final bool showLimitMessage;
  final int chatLimit; // Remove final
  final Function(String) onSendMessage;
  final VoidCallback onLimitReached;
  final List<String> faqs;
  final bool hideHistory;

  const ChatUI({
    super.key,
    required this.messages,
    required this.textController,
    required this.scrollController,
    required this.isLoading,
    required this.showLimitMessage,
    required this.chatLimit,
    required this.onSendMessage,
    required this.onLimitReached,
    required this.faqs,
    required this.hideHistory,
  });

  String _getMessageDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(messageDate);
    }
  }

  Widget _buildDateSeparator(String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                date,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, BuildContext context) {
    final timeString = DateFormat('HH:mm').format(message.timestamp);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Container(
          decoration: BoxDecoration(
            color: message.isUser
                ? const Color(0xFFDCF8C6).withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(message.isUser ? 15 : 0),
              topRight: Radius.circular(message.isUser ? 0 : 15),
              bottomLeft: const Radius.circular(15),
              bottomRight: const Radius.circular(15),
            ),
            boxShadow: [
              // Outer shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
              // Inner shadow
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: -1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 0.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: message.isUser
                        ? [
                      const Color(0xFFDCF8C6).withOpacity(0.9),
                      const Color(0xFFDCF8C6).withOpacity(0.7),
                    ]
                        : [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeString,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => _buildDot(index)),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.grey[300],
              Colors.grey[600],
              (value + index / 3) % 1,
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final groupedMessages = <String, List<ChatMessage>>{};
    for (var message in messages) {
      final date = _getMessageDate(message.timestamp);
      if (!groupedMessages.containsKey(date)) {
        groupedMessages[date] = [];
      }
      groupedMessages[date]!.add(message);
    }

    final sortedDates = groupedMessages.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // WhatsApp background pattern
        color: const Color(0xFFE5DDD5),
        image: const DecorationImage(
          image: NetworkImage(
              'https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png'
          ),
          repeat: ImageRepeat.repeat,
          opacity: 0.1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          //Header......
          // FAQs Section - Now always visible
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Quick Questions:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: faqs.map((faq) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: Text(
                          faq,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[800],
                          ),
                        ),
                        backgroundColor: Colors.green[50],
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        onPressed: (chatLimit > 0)
                            ? () => onSendMessage(faq)
                            : onLimitReached,
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Chat Messages
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                controller: scrollController,
                reverse: true,
                padding: const EdgeInsets.all(8),
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final messagesForDate = groupedMessages[date]!;
                  return Column(
                    children: [
                      _buildDateSeparator(date),
                      ...messagesForDate.map((message) =>
                          _buildMessageBubble(message, context)
                      ).toList().reversed,
                    ],
                  );
                },
              ),
            ),
          ),

          // Typing Indicator
          if (isLoading) _buildTypingIndicator(),

          // Input Section
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Ask about plant care...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    enabled: chatLimit > 0,
                    onSubmitted: (chatLimit > 0)
                        ? (value) {
                      if (value.isNotEmpty) {
                        onSendMessage(value);
                        textController.clear();
                      }
                    }
                        : null,

                  ),
                ),
                IconButton(
                  // icon: Icon(Icons.send),
                  icon: const Icon(Symbols.keyboard_double_arrow_right),
                  color: Colors.green,
                  onPressed: (chatLimit > 0)
                      ? () {
                    final query = textController.text.trim();
                    if (query.isNotEmpty) {
                      onSendMessage(query);
                      textController.clear();
                    }
                  }
                      : onLimitReached,
                ),
              ],
            ),
          ),

          // Remaining Chats Counter
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Chats remaining: $chatLimit",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}