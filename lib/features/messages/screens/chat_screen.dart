import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/services/convex_service.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String itemTitle;
  final double itemPrice;
  final String? itemImage;
  final bool isSeller;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    required this.itemTitle,
    required this.itemPrice,
    this.itemImage,
    required this.isSeller,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingSubscription;
  
  List<dynamic> _messages = [];
  List<dynamic> _typingUsers = [];
  bool _isLoading = true;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _setupTypingListener();
  }

  Future<void> _initializeChat() async {
    // Load initial messages
    try {
      final messages = await ConvexFunctions.getMessages(widget.conversationId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();

      // Subscribe to new messages
      _messagesSubscription = ConvexFunctions.subscribeToMessages(widget.conversationId).listen((messages) {
        setState(() {
          _messages = messages;
        });
        _scrollToBottom();
      });

      // Mark messages as read
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        await ConvexFunctions.markMessagesAsRead(
          conversationId: widget.conversationId,
          userId: userId,
        );
      }

      // Subscribe to typing indicators
      if (userId != null) {
        _typingSubscription = ConvexFunctions.subscribeToTypingUsers(
          conversationId: widget.conversationId,
          currentUserId: userId,
        ).listen((users) {
          setState(() {
            _typingUsers = users;
          });
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load messages');
    }
  }

  void _setupTypingListener() {
    _messageController.addListener(() {
      if (_messageController.text.isNotEmpty) {
        _sendTypingIndicator(true);
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 2), () {
          _sendTypingIndicator(false);
        });
      }
    });
  }

  Future<void> _sendTypingIndicator(bool isTyping) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await ConvexFunctions.setTyping(
        conversationId: widget.conversationId,
        userId: userId,
        isTyping: isTyping,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      _showError('User not authenticated');
      return;
    }

    _messageController.clear();
    _sendTypingIndicator(false);

    try {
      await ConvexFunctions.sendMessage(
        conversationId: widget.conversationId,
        senderId: userId,
        content: message,
      );
    } catch (e) {
      _showError('Failed to send message');
    }
  }

  Future<void> _sendOffer(double amount) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      await ConvexFunctions.sendMessage(
        conversationId: widget.conversationId,
        senderId: userId,
        content: 'Made an offer: \$${amount.toStringAsFixed(2)}',
        type: 'offer',
        metadata: {'offerAmount': amount},
      );
    } catch (e) {
      _showError('Failed to send offer');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showOfferDialog() {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController offerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.makeOffer),
        content: TextField(
          controller: offerController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter offer amount',
            prefixText: '\$',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(offerController.text);
              if (amount != null && amount > 0) {
                _sendOffer(amount);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: Text(l10n.sendOffer),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.itemTitle,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            onPressed: () {
              // TODO: Show conversation options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Item info bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                if (widget.itemImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.itemImage!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: AppTheme.borderColor,
                        child: const Icon(Icons.image, color: AppTheme.textHint),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.itemTitle,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${widget.itemPrice.toStringAsFixed(2)}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isSeller)
                  ElevatedButton(
                    onPressed: _showOfferDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      l10n.makeOffer,
                      style: AppTheme.button.copyWith(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_typingUsers.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _typingUsers.isNotEmpty) {
                        return TypingIndicator(users: _typingUsers);
                      }
                      
                      final message = _messages[index];
                      final isMe = message['senderId'] == userId;
                      
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.05),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate, color: AppTheme.textSecondary),
                    onPressed: () {
                      // TODO: Implement image picking
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: l10n.typeMessage,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}