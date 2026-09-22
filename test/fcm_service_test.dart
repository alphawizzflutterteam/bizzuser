import 'package:flutter_test/flutter_test.dart';

import 'package:bizzuser/data/services/fcm_service.dart';

void main() {
  test('getToken never throws when Firebase is unavailable', () async {
    expect(await FcmService().getToken(), '');
  });
}
