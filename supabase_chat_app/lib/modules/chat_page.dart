import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/message.dart';
import '../models/profile.dart';
import '../utils/constants.dart';
import '../utils/extensions.dart';
import '../widgets/chat_bubble.dart';

/// Page to chat with someone.
///
/// Displays chat bubbles as a ListView and TextField to enter new chat.
class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ChatPage(),
    );
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // late final Stream<List<Message>> _messagesStream;
  final Map<String, Profile> _profileCache = {};
  List<Message> messages = [];

  @override
  void initState() {
    final myUserId = supabase.auth.currentUser?.id;
    super.initState();

    _getAllMessages(myUserId).then((_) => supabase
        .channel('public:countries')
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            callback: (payload) async {
              final oldSeenBy = payload.newRecord['seen_by'];
              final updatedSeenBy = !oldSeenBy.contains(myUserId)
                  ? [...oldSeenBy, myUserId]
                  : oldSeenBy;

              await supabase.from('messages').update({
                'seen_by': updatedSeenBy,
              }).eq('id', payload.newRecord['id']);

              setState(() {
                messages.add(
                  Message.fromMap(
                      map: payload.newRecord, myUserId: myUserId ?? ''),
                );
              });
            })
        .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              _handleMessageUpdate(payload);
            })
        .subscribe());
  }

  Future<void> _loadProfileCache(String profileId) async {
    if (_profileCache[profileId] != null) {
      return;
    }
    final data =
        await supabase.from('profiles').select().eq('id', profileId).single();
    final profile = Profile.fromMap(data);
    setState(() {
      _profileCache[profileId] = profile;
    });
  }

  Future<int> _getAllMessages(String? myUserId) async {
    final _messages = await supabase.from('messages').select('*');
    final List<Message> fetchedMessages = _messages
        .map((message) =>
            Message.fromMap(map: message, myUserId: myUserId ?? ''))
        .toList();

    for (var message in fetchedMessages) {
      final oldSeenBy = List<String>.from(message.seenBy);
      if (!oldSeenBy.contains(myUserId)) {
        final updatedSeenBy = [...oldSeenBy, myUserId!];
        await supabase.from('messages').update({
          'seen_by': updatedSeenBy,
        }).eq('id', message.id);
      }
    }

    setState(() {
      messages = fetchedMessages;
    });
    return 0;
  }

  void _handleMessageUpdate(PostgresChangePayload payload) {
    setState(() {
      final updatedMessage = Message.fromMap(
        map: payload.newRecord,
        myUserId: supabase.auth.currentUser?.id ?? '',
      );
      final index = messages.indexWhere((msg) => msg.id == updatedMessage.id);
      if (index != -1) {
        messages[index] = updatedMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('Start your conversation now :)'),
                  )
                : ListView.builder(
                    // reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      /// I know it's not good to include code that is not related
                      /// to rendering the widget inside build method, but for
                      /// creating an app quick and dirty, it's fine 😂
                      _loadProfileCache(message.profileId);

                      return ChatBubble(
                        message: message,
                        profile: _profileCache[message.profileId],
                      );
                    },
                  ),
          ),
          const _MessageBar(),
        ],
      ),
    );
  }
}

/// Set of widget that contains TextField and Button to submit message
class _MessageBar extends StatefulWidget {
  const _MessageBar({
    Key? key,
  }) : super(key: key);

  @override
  State<_MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  autofocus: true,
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _submitMessage(),
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final text = _textController.text;
    final myUserId = supabase.auth.currentUser?.id;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    print("text $text myuserid $myUserId");
    try {
      await supabase.from('messages').insert({
        'profile_id': myUserId,
        'content': text,
        'seen_by': [myUserId],
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}

enum MessageStatus { SEEN_BY_ALL, NOT_SEEN_BY_ALL }
