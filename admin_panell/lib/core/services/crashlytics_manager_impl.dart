import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'crashlytics_manager.dart';

/// تنفيذ مدير تقارير الأعطال باستخدام Firebase Crashlytics
class CrashlyticsManagerImpl extends CrashlyticsManager {
  CrashlyticsManagerImpl({FirebaseCrashlytics? crashlytics})
      : super(crashlytics: crashlytics);
}
