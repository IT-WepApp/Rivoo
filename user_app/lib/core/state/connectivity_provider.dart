import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// مزود حالة الاتصال بالإنترنت
/// يستخدم لمراقبة حالة الاتصال بالإنترنت وتوفير تحديثات مباشرة
@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  late final Connectivity _connectivity;
  
  @override
  Stream<ConnectivityResult> build() {
    _connectivity = Connectivity();
    return _connectivity.onConnectivityChanged;
  }
  
  /// التحقق من حالة الاتصال الحالية
  Future<ConnectivityResult> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }
  
  /// التحقق مما إذا كان الجهاز متصلاً بالإنترنت
  Future<bool> isConnected() async {
    final result = await checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

/// مزود قراءة فقط لحالة الاتصال بالإنترنت
@riverpod
Future<bool> isNetworkConnected(IsNetworkConnectedRef ref) async {
  final connectivityNotifier = ref.watch(connectivityNotifierProvider.notifier);
  return await connectivityNotifier.isConnected();
}
