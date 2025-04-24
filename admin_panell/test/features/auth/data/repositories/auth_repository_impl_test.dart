import 'package:admin_panell/core/services/crashlytics_manager.dart';
import 'package:admin_panell/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:admin_panell/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mockito/annotations.dart';


@GenerateMocks([AuthRemoteDataSource, AuthLocalDataSource, CrashlyticsManager])
void main() {
  // تنفيذ اختبارات مستودع المصادقة
}
