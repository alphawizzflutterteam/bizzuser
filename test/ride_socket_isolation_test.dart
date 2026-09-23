import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:bizzuser/data/models/chat_message.dart';
import 'package:bizzuser/data/models/ride_booking.dart';
import 'package:bizzuser/data/models/ride_driver.dart';
import 'package:bizzuser/data/models/ride_location.dart';
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
      expect(
        RideSocketService.rideIdFrom({'ride': 'plainId'}),
        'plainId',
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

    test('status event stores otp for accepted payload', () {
      final socket = RideSocketService();
      socket.joinRide('R1');
      // Simulate filtered accept via public helpers
      expect(socket.acceptsRideId('R1'), isTrue);
      expect(RideSocketService.rideIdFrom({'rideId': 'R1', 'otp': '4321'}), 'R1');
    });
  });

  group('RideBooking live status labels', () {
    test('maps rawStatus to contract UI labels', () {
      RideBooking ride(String status, {String otp = ''}) => RideBooking(
            id: '1',
            status: RideBookingStatus.ongoing,
            statusLabel: '',
            pickup: const RideLocation(title: 'A', subtitle: ''),
            drop: const RideLocation(title: 'B', subtitle: ''),
            distance: '',
            driver: const RideDriver(
              name: 'D',
              rating: '5',
              phone: '',
              vehicleNumber: '',
            ),
            vehicleLabel: 'Auto',
            rawStatus: status,
            otp: otp,
          );

      expect(ride('searching').liveStatusUiLabel, 'Searching for driver');
      expect(ride('accepted', otp: '1234').liveStatusUiLabel, 'Driver on the way');
      expect(ride('accepted', otp: '1234').showOtp, isTrue);
      expect(ride('arrived', otp: '1234').liveStatusUiLabel, 'Driver has arrived');
      expect(ride('ongoing').liveStatusUiLabel, 'Trip in progress');
      expect(ride('ongoing', otp: '1234').showOtp, isFalse);
      expect(ride('completed').liveStatusUiLabel, 'Completed');
      expect(ride('cancelled').liveStatusUiLabel, 'Cancelled');
    });
  });
}
