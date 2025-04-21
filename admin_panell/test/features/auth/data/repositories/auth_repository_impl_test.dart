import 'package:admin_panell/core/services/crashlytics_manager.dart';
import 'package:admin_panell/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:admin_panell/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:admin_panell/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:admin_panell/features/auth/domain/entities/user.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';

@GenerateMocks([AuthRemoteDataSource, AuthLocalDataSource, CrashlyticsManager])
void main() {
  // تنفيذ اختبارات مستودع المصادقة
}
