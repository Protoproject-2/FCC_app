import 'package:flutter_riverpod/flutter_riverpod.dart';

final qrCodeRepositoryProvider = Provider<QrCodeRepository>((ref) {
  return QrCodeRepositoryImpl();
});

abstract class QrCodeRepository {
  String createQrCodeUrl(String data);
}

class QrCodeRepositoryImpl implements QrCodeRepository {
  @override
  String createQrCodeUrl(String data) {
    return 'https://api.qrserver.com/v1/create-qr-code/?size=240x240&data=${Uri.encodeComponent(data)}';
  }
}
