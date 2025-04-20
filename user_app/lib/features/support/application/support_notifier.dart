import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_app/features/support/application/support_service.dart';
import 'package:user_app/features/support/domain/ticket.dart';

/// حالة الدعم الفني
class SupportState {
  final List<SupportTicket> tickets;
  final SupportTicket? selectedTicket;
  final List<SupportMessage> messages;
  final bool isLoading;
  final String? error;

  const SupportState({
    this.tickets = const [],
    this.selectedTicket,
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  SupportState copyWith({
    List<SupportTicket>? tickets,
    SupportTicket? selectedTicket,
    List<SupportMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return SupportState(
      tickets: tickets ?? this.tickets,
      selectedTicket: selectedTicket ?? this.selectedTicket,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// مزود حالة الدعم الفني
final supportNotifierProvider =
    StateNotifierProvider<SupportNotifier, SupportState>((ref) {
  final supportService = ref.watch(supportServiceProvider);
  return SupportNotifier(supportService);
});

/// مزود تدفق تذاكر المستخدم
final userTicketsProvider = StreamProvider<List<SupportTicket>>((ref) {
  final supportService = ref.watch(supportServiceProvider);
  return supportService.getUserTickets();
});

/// مزود تدفق تذكرة محددة
final selectedTicketProvider =
    StreamProvider.family<SupportTicket?, String>((ref, ticketId) {
  final supportService = ref.watch(supportServiceProvider);
  return supportService.getTicket(ticketId);
});

/// مزود تدفق رسائل تذكرة محددة
final ticketMessagesProvider =
    StreamProvider.family<List<SupportMessage>, String>((ref, ticketId) {
  final supportService = ref.watch(supportServiceProvider);
  return supportService.getTicketMessages(ticketId);
});

/// مدير حالة الدعم الفني
class SupportNotifier extends StateNotifier<SupportState> {
  final SupportService _supportService;

  SupportNotifier(this._supportService) : super(const SupportState());

  /// إنشاء تذكرة دعم جديدة
  Future<void> createTicket({
    required String subject,
    required String description,
    required TicketType type,
    TicketPriority priority = TicketPriority.medium,
    String? orderId,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final ticket = await _supportService.createTicket(
        subject: subject,
        description: description,
        type: type,
        priority: priority,
        orderId: orderId,
      );
      
      state = state.copyWith(
        isLoading: false,
        selectedTicket: ticket,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// تحديد تذكرة نشطة
  void selectTicket(SupportTicket? ticket) {
    state = state.copyWith(
      selectedTicket: ticket,
      messages: [],
    );
    
    if (ticket != null) {
      _supportService.markMessagesAsRead(ticket.id);
    }
  }

  /// إرسال رسالة
  Future<void> sendMessage({
    required String message,
    String? attachmentPath,
  }) async {
    try {
      if (state.selectedTicket == null) {
        throw Exception('لم يتم تحديد تذكرة');
      }
      
      state = state.copyWith(isLoading: true, error: null);
      
      await _supportService.sendMessage(
        ticketId: state.selectedTicket!.id,
        message: message,
        attachmentPath: attachmentPath,
      );
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// إغلاق تذكرة
  Future<void> closeTicket() async {
    try {
      if (state.selectedTicket == null) {
        throw Exception('لم يتم تحديد تذكرة');
      }
      
      state = state.copyWith(isLoading: true, error: null);
      
      await _supportService.closeTicket(state.selectedTicket!.id);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// إعادة فتح تذكرة
  Future<void> reopenTicket() async {
    try {
      if (state.selectedTicket == null) {
        throw Exception('لم يتم تحديد تذكرة');
      }
      
      state = state.copyWith(isLoading: true, error: null);
      
      await _supportService.reopenTicket(state.selectedTicket!.id);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// تعليم الرسائل كمقروءة
  Future<void> markMessagesAsRead() async {
    try {
      if (state.selectedTicket == null) {
        return;
      }
      
      await _supportService.markMessagesAsRead(state.selectedTicket!.id);
    } catch (e) {
      // تجاهل الأخطاء هنا
    }
  }
}
