import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:admin_panell/features/auth/domain/repositories/auth_repository.dart';
import 'package:admin_panell/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:admin_panell/features/auth/domain/entities/user_entity.dart';

// توليد الملفات المطلوبة لـ Mockito
@GenerateMocks([AuthRepository])
import 'get_current_user_usecase_test.mocks.dart';

void main() {
  late GetCurrentUserUseCase getCurrentUserUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    getCurrentUserUseCase = GetCurrentUserUseCase(mockAuthRepository);
  });

  final testUser = UserEntity(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    role: 'admin',
  );

  test('يجب أن يقوم GetCurrentUserUseCase باستدعاء مستودع المصادقة ويعيد المستخدم الحالي', () async {
    // ترتيب
    when(mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => testUser);

    // تنفيذ
    final result = await getCurrentUserUseCase.execute();

    // تحقق
    expect(result, equals(testUser));
    verify(mockAuthRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('يجب أن يعيد GetCurrentUserUseCase قيمة null عندما لا يوجد مستخدم حالي', () async {
    // ترتيب
    when(mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => null);

    // تنفيذ
    final result = await getCurrentUserUseCase.execute();

    // تحقق
    expect(result, isNull);
    verify(mockAuthRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
