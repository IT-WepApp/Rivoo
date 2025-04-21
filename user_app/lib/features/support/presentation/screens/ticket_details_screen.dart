import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/utils/responsive_utils.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';
import 'package:user_app/features/support/application/support_notifier.dart';
import 'package:user_app/features/support/domain/ticket.dart';
import 'package:user_app/features/support/presentation/widgets/message_bubble.dart';
import 'package:intl/intl.dart';

class TicketDetailsScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailsScreen({
    Key? key,
    required this.ticketId,
  }) : super(key: key);

  @override
  ConsumerState<TicketDetailsScreen> createState() =>
      _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends ConsumerState<TicketDetailsScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // تعليم الرسائل كمقروءة عند فتح التذكرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportNotifierProvider.notifier).markMessagesAsRead();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ticketAsync = ref.watch(selectedTicketProvider(widget.ticketId));
    final messagesAsync = ref.watch(ticketMessagesProvider(widget.ticketId));

    return Scaffold(
      appBar: AppBar(
        title: ticketAsync.when(
          data: (ticket) => Text(ticket?.subject ?? l10n.ticketDetails),
          loading: () => Text(l10n.loading),
          error: (_, __) => Text(l10n.ticketDetails),
        ),
        actions: [
          ticketAsync.when(
            data: (ticket) {
              if (ticket == null) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'close') {
                    _closeTicket();
                  } else if (value == 'reopen') {
                    _reopenTicket();
                  }
                },
                itemBuilder: (context) {
                  return [
                    if (ticket.status != TicketStatus.closed)
                      PopupMenuItem<String>(
                        value: 'close',
                        child: Text(l10n.closeTicket),
                      ),
                    if (ticket.status == TicketStatus.closed)
                      PopupMenuItem<String>(
                        value: 'reopen',
                        child: Text(l10n.reopenTicket),
                      ),
                  ];
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: ResponsiveBuilder(
        // تنفيذ واجهة الهاتف
        mobileBuilder: (context) =>
            _buildMobileLayout(context, l10n, ticketAsync, messagesAsync),

        // تنفيذ واجهة الجهاز اللوحي
        smallTabletBuilder: (context) =>
            _buildTabletLayout(context, l10n, ticketAsync, messagesAsync),

        // تنفيذ واجهة سطح المكتب
        desktopBuilder: (context) =>
            _buildDesktopLayout(context, l10n, ticketAsync, messagesAsync),
      ),
    );
  }

  // بناء تخطيط الهاتف
  Widget _buildMobileLayout(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<SupportTicket?> ticketAsync,
    AsyncValue<List<SupportMessage>> messagesAsync,
  ) {
    return Column(
      children: [
        // معلومات التذكرة
        ticketAsync.when(
          data: (ticket) {
            if (ticket == null) {
              return const Center(child: Text('التذكرة غير موجودة'));
            }

            return _buildTicketInfoCard(context, l10n, ticket);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'حدث خطأ: ${error.toString()}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),

        // رسائل المحادثة
        Expanded(
          child: messagesAsync.when(
            data: (messages) {
              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد رسائل بعد',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              return _buildMessagesList(context, messages);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'حدث خطأ: ${error.toString()}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),

        // حقل إدخال الرسالة
        ticketAsync.when(
          data: (ticket) {
            if (ticket == null || ticket.status == TicketStatus.closed) {
              return const SizedBox.shrink();
            }

            return _buildMessageInput(context, l10n);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  // بناء تخطيط الجهاز اللوحي
  Widget _buildTabletLayout(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<SupportTicket?> ticketAsync,
    AsyncValue<List<SupportMessage>> messagesAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // معلومات التذكرة
          ticketAsync.when(
            data: (ticket) {
              if (ticket == null) {
                return const Center(child: Text('التذكرة غير موجودة'));
              }

              return _buildTicketInfoCard(context, l10n, ticket);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'حدث خطأ: ${error.toString()}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),

          // رسائل المحادثة
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد رسائل بعد',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return _buildMessagesList(context, messages);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(
                      'حدث خطأ: ${error.toString()}',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // حقل إدخال الرسالة
          ticketAsync.when(
            data: (ticket) {
              if (ticket == null || ticket.status == TicketStatus.closed) {
                return const SizedBox.shrink();
              }

              return _buildMessageInput(context, l10n);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // بناء تخطيط سطح المكتب
  Widget _buildDesktopLayout(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<SupportTicket?> ticketAsync,
    AsyncValue<List<SupportMessage>> messagesAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات التذكرة
          Expanded(
            flex: 3,
            child: ticketAsync.when(
              data: (ticket) {
                if (ticket == null) {
                  return const Center(child: Text('التذكرة غير موجودة'));
                }

                return _buildDetailedTicketInfo(context, l10n, ticket);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'حدث خطأ: ${error.toString()}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ),

          const SizedBox(width: 24),

          // رسائل المحادثة
          Expanded(
            flex: 7,
            child: Column(
              children: [
                // عنوان المحادثة
                Row(
                  children: [
                    Text(
                      l10n.conversation,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
                    ticketAsync.when(
                      data: (ticket) {
                        if (ticket == null) {
                          return const SizedBox.shrink();
                        }

                        return ticket.status == TicketStatus.closed
                            ? OutlinedButton.icon(
                                onPressed: _reopenTicket,
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n.reopenTicket),
                              )
                            : OutlinedButton.icon(
                                onPressed: _closeTicket,
                                icon: const Icon(Icons.check_circle),
                                label: Text(l10n.closeTicket),
                              );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // رسائل المحادثة
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: messagesAsync.when(
                        data: (messages) {
                          if (messages.isEmpty) {
                            return Center(
                              child: Text(
                                'لا توجد رسائل بعد',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            );
                          }

                          return _buildMessagesList(context, messages);
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: Text(
                            'حدث خطأ: ${error.toString()}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // حقل إدخال الرسالة
                ticketAsync.when(
                  data: (ticket) {
                    if (ticket == null ||
                        ticket.status == TicketStatus.closed) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: _buildMessageInput(context, l10n),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء بطاقة معلومات التذكرة
  Widget _buildTicketInfoCard(
    BuildContext context,
    AppLocalizations l10n,
    SupportTicket ticket,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              children: [
                // رمز نوع التذكرة
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 26), // 0.1 * 255 = 26
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTicketTypeIcon(ticket.type),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),

                // معلومات التذكرة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.subject,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تذكرة #${ticket.id.substring(0, 8)} • ${_formatDate(ticket.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 179), // 0.7 * 255 = 179
                            ),
                      ),
                    ],
                  ),
                ),

                // حالة التذكرة
                _buildStatusChip(context, ticket.status),
              ],
            ),

            // وصف التذكرة
            if (context.isPhone) ...[
              const Divider(height: 24),
              Text(
                l10n.description,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                ticket.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (ticket.description.length > 150) ...[
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    // عرض الوصف كاملاً
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.description),
                        content: SingleChildScrollView(
                          child: Text(ticket.description),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.close),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(l10n.readMore),
                ),
              ],
            ],

            // معلومات إضافية
            if (context.isPhone) ...[
              const Divider(height: 24),
              Row(
                children: [
                  // الأولوية
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.priority,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        _buildPriorityChip(context, ticket.priority),
                      ],
                    ),
                  ),

                  // النوع
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.type,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTicketTypeName(ticket.type),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // بناء معلومات التذكرة المفصلة
  Widget _buildDetailedTicketInfo(
    BuildContext context,
    AppLocalizations l10n,
    SupportTicket ticket,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Text(
              l10n.ticketDetails,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // رمز نوع التذكرة
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 26), // 0.1 * 255 = 26
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTicketTypeIcon(ticket.type),
                  color: Theme.of(context).colorScheme.primary,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // موضوع التذكرة
            Center(
              child: Text(
                ticket.subject,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // معرف التذكرة والتاريخ
            Center(
              child: Text(
                'تذكرة #${ticket.id.substring(0, 8)} • ${_formatDate(ticket.createdAt)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 179), // 0.7 * 255 = 179
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // حالة التذكرة
            _buildInfoRow(
              context,
              l10n.status,
              _buildStatusChip(context, ticket.status),
            ),
            const SizedBox(height: 16),

            // أولوية التذكرة
            _buildInfoRow(
              context,
              l10n.priority,
              _buildPriorityChip(context, ticket.priority),
            ),
            const SizedBox(height: 16),

            // نوع التذكرة
            _buildInfoRow(
              context,
              l10n.type,
              Text(
                _getTicketTypeName(ticket.type),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // رقم الطلب إذا كان موجوداً
            if (ticket.orderId != null) ...[
              _buildInfoRow(
                context,
                l10n.orderNumber,
                TextButton(
                  onPressed: () {
                    // الانتقال إلى صفحة تفاصيل الطلب
                  },
                  child: Text('#${ticket.orderId}'),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // وصف التذكرة
            Text(
              l10n.description,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Text(
                ticket.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),

            // زر إغلاق/إعادة فتح التذكرة
            Center(
              child: ticket.status == TicketStatus.closed
                  ? ElevatedButton.icon(
                      onPressed: _reopenTicket,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.reopenTicket),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: _closeTicket,
                      icon: const Icon(Icons.check_circle),
                      label: Text(l10n.closeTicket),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء صف معلومات
  Widget _buildInfoRow(BuildContext context, String label, Widget value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        value,
      ],
    );
  }

  // بناء قائمة الرسائل
  Widget _buildMessagesList(
    BuildContext context,
    List<SupportMessage> messages,
  ) {
    // ترتيب الرسائل حسب التاريخ
    final sortedMessages = List<SupportMessage>.from(messages)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: sortedMessages.length,
      itemBuilder: (context, index) {
        final message = sortedMessages[index];
        final showAvatar = index == 0 ||
            sortedMessages[index - 1].isFromSupport != message.isFromSupport;

        return MessageBubble(
          message: message,
          showAvatar: showAvatar,
        );
      },
    );
  }

  // بناء حقل إدخال الرسالة
  Widget _buildMessageInput(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 13), // 0.05 * 255 = 13
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر إرفاق ملف
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // إضافة مرفق
            },
          ),

          // حقل إدخال النص
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: l10n.typeYourMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          const SizedBox(width: 8),

          // زر الإرسال
          IconButton(
            icon: _isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: _isSending ? null : _sendMessage,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  // إرسال رسالة
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await ref.read(supportNotifierProvider.notifier).sendMessage(
            ticketId: widget.ticketId,
            message: message,
          );

      _messageController.clear();

      // التمرير إلى أسفل القائمة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // إغلاق التذكرة
  Future<void> _closeTicket() async {
    try {
      await ref
          .read(supportNotifierProvider.notifier)
          .updateTicketStatus(widget.ticketId, TicketStatus.closed);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إغلاق التذكرة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // إعادة فتح التذكرة
  Future<void> _reopenTicket() async {
    try {
      await ref
          .read(supportNotifierProvider.notifier)
          .updateTicketStatus(widget.ticketId, TicketStatus.open);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إعادة فتح التذكرة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // بناء شريحة الحالة
  Widget _buildStatusChip(BuildContext context, TicketStatus status) {
    String label;
    Color color;

    switch (status) {
      case TicketStatus.open:
        label = 'مفتوحة';
        color = Colors.blue;
        break;
      case TicketStatus.pending:
        label = 'قيد الانتظار';
        color = Colors.orange;
        break;
      case TicketStatus.resolved:
        label = 'تم الحل';
        color = Colors.green;
        break;
      case TicketStatus.closed:
        label = 'مغلقة';
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 26), // 0.1 * 255 = 26
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // بناء شريحة الأولوية
  Widget _buildPriorityChip(BuildContext context, TicketPriority priority) {
    String label;
    Color color;

    switch (priority) {
      case TicketPriority.low:
        label = 'منخفضة';
        color = Colors.green;
        break;
      case TicketPriority.medium:
        label = 'متوسطة';
        color = Colors.blue;
        break;
      case TicketPriority.high:
        label = 'عالية';
        color = Colors.orange;
        break;
      case TicketPriority.urgent:
        label = 'عاجلة';
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 26), // 0.1 * 255 = 26
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // الحصول على أيقونة نوع التذكرة
  IconData _getTicketTypeIcon(TicketType type) {
    switch (type) {
      case TicketType.general:
        return Icons.help_outline;
      case TicketType.orderIssue:
        return Icons.shopping_bag;
      case TicketType.paymentIssue:
        return Icons.payment;
      case TicketType.accountIssue:
        return Icons.person;
      case TicketType.appIssue:
        return Icons.smartphone;
      case TicketType.suggestion:
        return Icons.lightbulb_outline;
      case TicketType.other:
        return Icons.more_horiz;
    }
  }

  // الحصول على اسم نوع التذكرة
  String _getTicketTypeName(TicketType type) {
    switch (type) {
      case TicketType.general:
        return 'استفسار عام';
      case TicketType.orderIssue:
        return 'مشكلة في الطلب';
      case TicketType.paymentIssue:
        return 'مشكلة في الدفع';
      case TicketType.accountIssue:
        return 'مشكلة في الحساب';
      case TicketType.appIssue:
        return 'مشكلة في التطبيق';
      case TicketType.suggestion:
        return 'اقتراح';
      case TicketType.other:
        return 'أخرى';
    }
  }

  // تنسيق التاريخ
  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd HH:mm').format(date);
  }
}
