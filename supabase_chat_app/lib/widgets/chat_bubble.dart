import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';

import '../models/message.dart';
import '../models/profile.dart';
import '../modules/chat_page.dart';
import '../utils/constants.dart';

class ChatBubble extends StatefulWidget {
  ChatBubble({
    Key? key,
    required this.message,
    required this.profile,
  }) : super(key: key);

  final Message message;
  final Profile? profile;

  @override
  State<ChatBubble> createState() => ChatBubbleState();
}

class ChatBubbleState extends State<ChatBubble> {
  MessageStatus status = MessageStatus.NOT_SEEN_BY_ALL;

  @override
  void initState() {
    super.initState();
    getStatusOfMessage(widget.message);
  }

  @override
  void didUpdateWidget(covariant ChatBubble oldWidget) {
    // if (widget.message.seenBy.length != oldWidget.message.seenBy.length) {
    getStatusOfMessage(widget.message);
    // }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!widget.message.isMine)
        CircleAvatar(
          child: widget.profile == null
              ? preloader
              : Text(widget.profile!.username.substring(0, 2)),
        ),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: widget.message.isMine
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: widget.message.isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                widget.message.content,
                style: TextStyle(
                  color: widget.message.isMine ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    format(widget.message.createdAt, locale: 'en_short'),
                    style: TextStyle(
                      color: widget.message.isMine
                          ? Colors.white60
                          : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  if (widget.message.isMine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      status == MessageStatus.SEEN_BY_ALL
                          ? Icons.done_all
                          : Icons.check,
                      color: status == MessageStatus.SEEN_BY_ALL
                          ? Colors.blue
                          : Colors.black54,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      if (widget.message.isMine) const SizedBox(width: 12),
    ];

    if (widget.message.isMine) {
      chatContents = chatContents.reversed.toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment: widget.message.isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }

  Future<void> getStatusOfMessage(Message message) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        status = MessageStatus.NOT_SEEN_BY_ALL;
      });
      return;
    }

    // Get the current seen_by array
    final data = await supabase
        .from('messages')
        .select('seen_by')
        .eq('id', message.id)
        .single();

    List<String> seenBy = (data['seen_by'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // If the user hasn't seen the message yet, add their ID to the seen_by array
    if (!seenBy.contains(userId)) {
      seenBy.add(userId);

      // Update the seen_by array in the messages table
      await supabase.from('messages').update({
        'seen_by': seenBy,
      }).eq('id', message.id);
    }

    final profilesData = await supabase.from('profiles').select();

    if (mounted) {
      if (seenBy.length == profilesData.length) {
        setState(() {
          status = MessageStatus.SEEN_BY_ALL;
        });
      } else {
        setState(() {
          status = MessageStatus.NOT_SEEN_BY_ALL;
        });
      }
    }
  }
}
