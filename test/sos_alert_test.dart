import 'package:flutter_test/flutter_test.dart';

import 'package:bizzuser/core/constants/app_strings.dart';
import 'package:bizzuser/core/exceptions/api_exception.dart';
import 'package:bizzuser/data/models/auth_session.dart';
import 'package:bizzuser/data/models/sos_alert.dart';
import 'package:bizzuser/data/repositories/safety_repository.dart';
import 'package:bizzuser/data/services/api_service.dart';

void main() {
  test('parses SOS raise payload and share text', () {
    final alert = SosAlert.fromJson({
      'success': true,
      'message': 'SOS raised',
      'data': {
        '_id': 'sos-22',
        'status': 'open',
        'raisedBy': 'user',
        'message': 'Need help',
        'lat': 22.74,
        'lng': 75.88,
        'rideId': 'ride-9',
        'sharePath': '/public/rides/share/abc',
        'shareUrl': 'https://example.com/public/rides/share/abc',
        'mapsUrl': 'https://www.google.com/maps?q=22.74,75.88',
        'sosNumbers': ['112', '100'],
        'emergencyContacts': [
          {'name': 'Neha', 'phone': '919000000011'},
        ],
        'contactsNotified': [
          {
            'name': 'Neha',
            'phone': '919000000011',
            'smsStatus': 'sent',
            'smsError': '',
          },
        ],
      },
    });

    expect(alert.id, 'sos-22');
    expect(alert.isOpen, isTrue);
    expect(alert.rideId, 'ride-9');
    expect(alert.sosNumbers, ['112', '100']);
    expect(alert.emergencyContacts.single.phone, '919000000011');
    expect(alert.contactsNotified.single.smsStatus, 'sent');
    expect(
      alert.shareText,
      'Emergency: I need help. Location: https://www.google.com/maps?q=22.74,75.88 Live trip: https://example.com/public/rides/share/abc',
    );
  });

  test('409 duplicate SOS envelope still parses as the open alert', () {
    final exception = ApiException(
      'SOS already open',
      statusCode: 409,
      data: {
        'success': false,
        'message': 'SOS already open',
        'data': {
          '_id': 'existing-sos',
          'status': 'open',
          'message': 'Need help',
          'lat': 22.7,
          'lng': 75.8,
        },
      },
    );
    final alert = SosAlert.fromJson(exception.data!);
    expect(alert.id, 'existing-sos');
    expect(alert.isOpen, isTrue);
  });

  test('null active SOS and empty contacts stay gated', () {
    expect(SosAlert.fromJson({'success': true, 'data': null}).id, isEmpty);
    expect(AuthUser.placeholder().hasEmergencyContact, isFalse);
    expect(const EmergencyContact(name: 'A').isValid, isFalse);
    expect(const EmergencyContact(name: 'A', phone: '9191').isValid, isTrue);
  });

  test('history page reads items envelope', () {
    final page = SosHistoryPage.fromJson({
      'success': true,
      'data': {
        'items': [
          {'_id': '1', 'status': 'cancelled', 'message': 'False alarm'},
        ],
        'total': 1,
        'page': 1,
        'limit': 20,
        'pages': 1,
      },
    });
    expect(page.total, 1);
    expect(page.items.single.status, 'cancelled');
    expect(page.items.single.message, 'False alarm');
  });

  test('raiseSos treats 409 with payload as success', () async {
    final repo = SafetyRepository(
      _FakeApi((path, body) async {
        expect(path, '/user/sos');
        expect(body['lat'], 22.74);
        expect(body.containsKey('rideId'), isFalse);
        throw const ApiException(
          'Already open',
          statusCode: 409,
          data: {
            'success': false,
            'message': 'Already open',
            'data': {
              '_id': 'open-1',
              'status': 'open',
              'message': 'Need help',
            },
          },
        );
      }),
    );

    final alert = await repo.raiseSos(lat: 22.74, lng: 75.88);
    expect(alert.id, 'open-1');
    expect(alert.isOpen, isTrue);
  });

  test('offline raise uses specified copy', () async {
    final repo = SafetyRepository(
      _FakeApi((path, body) async {
        throw const ApiException('SocketException: failed', statusCode: null);
      }),
    );
    expect(
      () => repo.raiseSos(lat: 1, lng: 2),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          AppStrings.unableToReachServer,
        ),
      ),
    );
  });
}

class _FakeApi extends ApiService {
  _FakeApi(this._onPost);

  final Future<Map<String, dynamic>> Function(
    String path,
    Map<String, dynamic> body,
  )
  _onPost;

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) {
    return _onPost(path, body);
  }
}
