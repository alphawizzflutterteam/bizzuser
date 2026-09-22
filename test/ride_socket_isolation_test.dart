import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:bizzuser/data/models/chat_message.dart';
import 'package:bizzuser/data/services/ride_socket_service.dart';

void main() {
  tearDown(Get.reset);

  group('RideSocketService rideId isolation', () {
    test('acceptsRideId only matches active ride', () {
      final socket = RideSocketService();
      expect(socket.acceptsRideId('R1'), isFalse);

      socket.joinRide('R1');
      expect(socket.acceptsRideId('R1'), isTrue);
      expect(socket.acceptsRideId('R2'), isFalse);
      expect(socket.acceptsRideId(''), isFalse);

      socket.leaveRide();
      expect(socket.acceptsRideId('R1'), isFalse);
    });

    test('rideIdFrom reads rideId or nested ride._id', () {
      expect(
        RideSocketService.rideIdFrom({'rideId': 'abc'}),
        'abc',
      );
      expect(
        RideSocketService.rideIdFrom({
          'ride': {'_id': 'nested1'},
        }),
        'nested1',
      );
      expect(RideSocketService.rideIdFrom({}), '');
    });

    test('ChatMessage parses rideId from payload', () {
      final message = ChatMessage.fromJson({
        'text': 'hello',
        'rideId': 'ride-9',
        'fromRole': 'driver',
        'createdAt': '2026-09-22T10:00:00.000Z',
      });
      expect(message.rideId, 'ride-9');
      expect(message.text, 'hello');
      expect(message.isMine, isFalse);
    });
  });
}
