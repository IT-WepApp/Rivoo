import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:user_app/core/utils/responsive_utils.dart';
import 'package:user_app/core/widgets/responsive_builder.dart';
import 'package:user_app/features/support/application/support_notifier.dart';
import 'package:user_app/features/support/domain/ticket.dart';
import 'package:user_app/features/support/presentation/widgets/ticket_card.dart';
import 'package:user_app/features/support/presentation/screens/ticket_details_screen.dart';
import 'package:user_app/features/support/presentation/screens/create_ticket_screen.dart';

class SupportTicketsScreen extends ConsumerWidget {
  const SupportTicketsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ticketsAsync = ref.watch(userTicketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.supportTickets),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // عرض صفحة المساعدة
            },
          ),
        ],
      ),
      body: ResponsiveBuilder(
        // تنفيذ واجهة الهاتف
        mobileBuilder: (context) => _buildMobileLayout(context, l10n, ticketsAsync),
        
        // تنفيذ واجهة الجهاز اللوحي
        smallTabletBuilder: (context) => _buildTabletLayout(context, l10n, ticketsAsync),
        
        // تنفيذ واجهة سطح المكتب
        desktopBuilder: (context) => _buildDesktopLayout(context, l10n, ticketsAsync),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTicketScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newTicket),
      ),
    );
  }

  // بناء تخطيط الهاتف
  Widget _buildMobileLayout(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<List<SupportTicket>> ticketsAsync,
  ) {
    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return _buildEmptyState(context, l10n);
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TicketCard(
                ticket: ticket,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketDetailsScreen(ticketId: ticket.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'حدث خطأ: ${error.toString()}',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // بناء تخطيط الجهاز اللوحي
  Widget _buildTabletLayout(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<List<SupportTicket>> ticketsAsync,
  ) {
    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return _buildEmptyState(context, l10n);
        }
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return TicketCard(
                ticket: ticket,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketDetailsScreen(ticketId: ticket.id),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'حدث خطأ: ${error.toString()}',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // بناء تخطيط سطح المكتب
  Widget _buildDesktopLayout(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<List<SupportTicket>> ticketsAsync,
  ) {
    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return _buildEmptyState(context, l10n);
        }
        
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان القسم
              Text(
                l10n.yourSupportTickets,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              
              // قائمة التذاكر
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // رأس الجدول
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  l10n.ticketId,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  l10n.subject,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  l10n.status,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  l10n.priority,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  l10n.createdAt,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                        const Divider(),
                        
                        // بيانات الجدول
                        Expanded(
                          child: ListView.separated(
                            itemCount: tickets.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final ticket = tickets[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TicketDetailsScreen(ticketId: ticket.id),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      // معرف التذكرة
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '#${ticket.id.substring(0, 8)}',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                      
                                      // الموضوع
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          ticket.subject,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      
                                      // الحالة
                                      Expanded(
                                        flex: 1,
                                        child: _buildStatusChip(context, ticket.status),
                                      ),
                                      
                                      // الأولوية
                                      Expanded(
                                        flex: 1,
                                        child: _buildPriorityChip(context, ticket.priority),
                                      ),
                                      
                                      // تاريخ الإنشاء
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _formatDate(ticket.createdAt),
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                      
                                      // زر الإجراءات
                                      SizedBox(
                                        width: 48,
                                        child: IconButton(
                                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => TicketDetailsScreen(ticketId: ticket.id),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'حدث خطأ: ${error.toString()}',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // بناء حالة فارغة
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent,
              size: context.responsiveIconSize(100),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noTicketsYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'لم تقم بإنشاء أي تذاكر دعم بعد. يمكنك إنشاء تذكرة جديدة للحصول على المساعدة.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ResponsiveButton(
              text: l10n.createNewTicket,
              icon: Icons.add,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTicketScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
