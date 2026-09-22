import 'package:bizzuser/core/constants/api_constants.dart';
import 'package:bizzuser/core/constants/app_strings.dart';
import 'package:bizzuser/core/utils/api_body.dart';
import 'package:bizzuser/core/utils/app_utils.dart';
import 'package:bizzuser/core/utils/media_url.dart';
import 'package:bizzuser/core/utils/phone_utils.dart';
import 'package:bizzuser/data/models/app_config.dart';
import 'package:bizzuser/data/models/app_notification.dart';
import 'package:bizzuser/data/models/auth_session.dart';
import 'package:bizzuser/data/models/chat_message.dart';
import 'package:bizzuser/data/models/cms_page.dart';
import 'package:bizzuser/data/models/legal_content.dart';
import 'package:bizzuser/data/models/otp_sent_data.dart';
import 'package:bizzuser/data/models/place_suggestion.dart';
import 'package:bizzuser/data/models/referral_info.dart';
import 'package:bizzuser/data/models/ride_booking.dart';
import 'package:bizzuser/data/models/ride_payment.dart';
import 'package:bizzuser/data/models/ride_coupon.dart';
import 'package:bizzuser/data/models/ride_estimate.dart';
import 'package:bizzuser/data/models/ride_location.dart';
import 'package:bizzuser/data/models/ride_vehicles_result.dart';
import 'package:bizzuser/data/models/signup_verify_data.dart';
import 'package:bizzuser/data/models/support_ticket.dart';
import 'package:bizzuser/data/models/user_address.dart';
import 'package:bizzuser/data/models/vehicle_type.dart';
import 'package:bizzuser/data/models/wallet_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneUtils', () {
    test('formats request phone as +91 and 10 digits', () {
      expect(PhoneUtils.toRequestPhone('9512345780'), '+91 9512345780');
      expect(PhoneUtils.toRequestPhone('+91 9512345780'), '+91 9512345780');
      expect(PhoneUtils.toRequestPhone('919512345780'), '+91 9512345780');
    });

    test('keeps compact 91XXXXXXXXXX for stored numbers', () {
      expect(PhoneUtils.toApiPhone('9876543210'), '919876543210');
      expect(PhoneUtils.toApiPhone('+91 98765 43210'), '919876543210');
    });

    test('formats visible phone as +91 98765 43210', () {
      expect(PhoneUtils.displayPhone('919876543210'), '+91 98765 43210');
      expect(PhoneUtils.displayPhone('9876543210'), '+91 98765 43210');
    });
  });

  group('ApiBody', () {
    test('reads success message', () {
      expect(
        ApiBody.message({'success': true, 'message': 'OTP sent'}),
        'OTP sent',
      );
    });

    test('prefers validation errors over generic message', () {
      expect(
        ApiBody.message({
          'success': false,
          'message': 'Validation failed',
          'errors': {
            'phone': ['Invalid phone number'],
          },
        }),
        'Invalid phone number',
      );
    });

    test('falls back when body is empty', () {
      expect(ApiBody.message(null), AppStrings.somethingWentWrong);
    });
  });

  group('OtpSentData', () {
    test('parses send otp payload including mask and resend window', () {
      final data = OtpSentData.fromJson({
        'success': true,
        'message': 'OTP sent',
        'data': {
          'phone': '919512345780',
          'maskedPhone': '+91 ********80',
          'otpLength': 4,
          'expiresInSec': 300,
          'resendInSec': 30,
          'devOtp': '8471',
        },
      });
      expect(data.message, 'OTP sent');
      expect(data.phone, '919512345780');
      expect(data.maskedPhone, '+91 ********80');
      expect(data.otpLength, 4);
      expect(data.expiresInSec, 300);
      expect(data.resendInSec, 30);
      expect(data.devOtp, '8471');
    });
  });

  group('SignupVerifyData', () {
    test('parses register verify-otp payload', () {
      final data = SignupVerifyData.fromJson({
        'success': true,
        'message': 'Mobile number verified',
        'data': {
          'signupToken': 'signup-token',
          'phone': '919512345780',
          'expiresInSec': 900,
        },
      });
      expect(data.message, 'Mobile number verified');
      expect(data.signupToken, 'signup-token');
      expect(data.phone, '919512345780');
      expect(data.expiresInSec, 900);
    });
  });

  group('AuthSession', () {
    test('parses login verify otp payload', () {
      final session = AuthSession.fromJson({
        'success': true,
        'message': 'Login successful',
        'data': {
          'token': 'test-token',
          'user': {
            'id': '66f0aa11bb22cc33dd44ee55',
            'name': 'Aarav Sharma',
            'phone': '919512345780',
            'email': 'aarav@example.com',
            'avatar': '',
            'city': 'Indore',
            'status': 'active',
            'walletBalance': 0,
            'rating': 5,
            'referralCode': 'BZ7K2MNP',
            'emergencyContacts': [],
            'notificationSettings': {
              'booking': true,
              'promo': true,
              'payment': true,
            },
          },
        },
      });
      expect(session.message, 'Login successful');
      expect(session.token, 'test-token');
      expect(session.user.name, 'Aarav Sharma');
      expect(session.user.phone, '919512345780');
      expect(session.user.referralCode, 'BZ7K2MNP');
      expect(session.user.notificationSettings['booking'], true);
    });

    test('parses account created payload', () {
      final session = AuthSession.fromJson({
        'success': true,
        'message': 'Account created',
        'data': {
          'token': 'created-token',
          'user': {'id': '1', 'name': 'Aarav Sharma', 'phone': '919512345780'},
        },
      }, fallbackMessage: AppStrings.accountCreated);
      expect(session.message, 'Account created');
      expect(session.token, 'created-token');
    });
  });

  group('otp subtitle', () {
    test('uses API masked phone as-is', () {
      expect(
        AppUtils.otpSubtitle('+91 ********80'),
        'Enter your 4 digit OTP sent on +91 ********80',
      );
    });
  });

  group('ProfileResult', () {
    test('parses GET /user/profile payload', () {
      final result = ProfileResult.fromJson({
        'success': true,
        'message': 'Profile fetched',
        'data': {
          'id': '66f0aa11bb22cc33dd44ee55',
          'name': 'Rahul Sharma',
          'phone': '919876543210',
          'email': 'rahul.s@example.com',
          'avatar': '/uploads/avatar.jpg',
          'city': 'Indore',
          'status': 'active',
          'walletBalance': 1250,
          'rating': 5,
          'ratingCount': 0,
          'referralCode': 'BZ7K2MNP',
          'emergencyContacts': [
            {'name': 'Neha Sharma', 'phone': '919000000011'},
          ],
          'bankAccount': {
            'accountName': 'Rahul Sharma',
            'accountNumber': '501234567890',
            'ifsc': 'HDFC0001234',
            'bankName': 'HDFC Bank',
            'accountType': 'savings',
          },
          'notificationSettings': {
            'booking': true,
            'promo': true,
            'payment': true,
          },
          'deleteRequested': false,
        },
      });
      expect(result.message, 'Profile fetched');
      expect(result.user.name, 'Rahul Sharma');
      expect(result.user.walletBalance, 1250);
      expect(result.user.referralCode, 'BZ7K2MNP');
      expect(result.user.hasEmergencyContact, isTrue);
      expect(result.user.emergencyContacts.first.phone, '919000000011');
      expect(result.user.bankAccount?.ifsc, 'HDFC0001234');
      expect(result.user.bankAccount?.displayType, AppStrings.savings);
      expect(result.user.deleteRequested, false);
    });
  });

  group('MediaUrl', () {
    test('resolves relative avatar paths against the API host', () {
      expect(
        MediaUrl.resolve('/uploads/avatar.jpg'),
        'https://bizzcab.developmentalphawizz.com/uploads/avatar.jpg',
      );
    });
  });

  group('grouped rupee', () {
    test('formats wallet balance with Indian grouping', () {
      expect(AppUtils.groupedRupee(1250), AppStrings.walletBalanceValue);
    });
  });

  group('support payloads', () {
    test('parses public app config for splash', () {
      final config = AppConfig.fromJson({
        'success': true,
        'message': 'App config fetched',
        'data': {
          'name': 'BizzCab',
          'tagline': 'Quick, comfortable, and spacious rides',
          'mobileLogo': '/uploads/mobile-logo.png',
          'logoLight': '',
          'email': 'support@bizzcab.com',
          'contactNo': '0731-4001000',
          'address': 'Vijay Nagar, Indore, Madhya Pradesh 452010',
          'sosNumbers': ['112', '100'],
          'defaultCity': 'Indore',
        },
      });
      expect(config.displayName, 'BizzCab');
      expect(config.displayTagline, 'Quick, comfortable, and spacious rides');
      expect(
        config.mobileLogoUrl,
        'https://bizzcab.developmentalphawizz.com/uploads/mobile-logo.png',
      );
      expect(config.sosNumbers, ['112', '100']);
      expect(config.defaultCity, 'Indore');
      expect(config.referralRewardAmount, 0);
    });

    test('parses referral reward amount from app config', () {
      final config = AppConfig.fromJson({
        'success': true,
        'data': {'name': 'BizzCab', 'referralRewardAmount': 50},
      });
      expect(config.referralRewardAmount, 50);
      expect(AppStrings.referEarnSplash(AppUtils.rupee(50)), contains('₹50'));
    });

    test('parses referral payload and wallet referral credit', () {
      final info = ReferralInfo.fromJson({
        'success': true,
        'data': {
          'referralCode': 'BZAARAV1',
          'referralRewardAmount': 50,
          'invitedCount': 1,
          'earnedAmount': 0,
          'pendingAmount': 50,
          'shareUrl': 'https://bizzcab.app/r/BZAARAV1',
          'referrals': [
            {'name': 'User B', 'status': 'pending', 'amount': 50},
          ],
        },
      });
      expect(info.code, 'BZAARAV1');
      expect(info.rewardAmount, 50);
      expect(info.invitedCount, 1);
      expect(info.pendingAmount, 50);
      expect(info.invites.single.name, 'User B');
      expect(info.pendingInvites.single.isPending, true);

      final history = ReferralHistory.fromJson({
        'success': true,
        'data': {
          'items': [
            {
              'invitee': {'name': 'User B'},
              'status': 'rewarded',
              'amount': 50,
              'rewardedAt': '2026-09-21T10:00:00.000Z',
            },
          ],
          'total': 1,
          'summary': {
            'invitedCount': 3,
            'earnedAmount': 50,
            'pendingAmount': 100,
          },
        },
      });
      expect(history.items.single.name, 'User B');
      expect(history.items.single.isRewarded, true);
      expect(history.items.single.statusLabel, AppStrings.statusRewarded);
      expect(history.total, 1);
      expect(history.invitedCount, 3);
      expect(history.earnedAmount, 50);
      expect(history.pendingAmount, 100);
      expect(ApiConstants.referralHistory, '/user/referral/history');

      final txn = WalletTransaction.fromJson({
        'type': 'credit',
        'amount': 50,
        'reason': 'referral_reward',
        'balanceAfter': 50,
        'createdAt': '2026-09-21T10:00:00.000Z',
      });
      expect(txn.isCredit, true);
      expect(txn.title, AppStrings.referralReward);
      expect(txn.subtitle, AppStrings.referralRewardHint);
    });

    test('parses public vehicle types', () {
      final types = ApiBody.dataList({
        'success': true,
        'data': [
          {
            '_id': '6aaba7fcb46e5ea3da9180cc',
            'name': '2-Wheeler',
            'tagline': 'Quick & Affordable',
            'shortName': 'Bike',
            'baseFare': 20,
            'perKm': 8,
            'minFare': 30,
            'capacity': 1,
            'icon': '',
            'active': true,
            'label': '2-Wheeler (Bike)',
          },
          {
            '_id': '6aaba7fcb46e5ea3da9180cf',
            'name': '3-Wheeler',
            'tagline': 'Comfortable Ride',
            'shortName': 'Auto',
            'minFare': 40,
            'active': true,
          },
        ],
      }).map(VehicleType.fromJson).toList();
      expect(types.first.toCategory().title, '2-Wheeler');
      expect(types.first.toOption().name, 'Bike');
      expect(types.first.toOption().price, 30);
      expect(types.last.tagline, 'Comfortable Ride');
    });

    test('uses existing auth and profile routes for FCM token', () {
      expect(ApiConstants.verifyOtp, '/user/auth/verify-otp');
      expect(ApiConstants.register, '/user/auth/register');
      expect(ApiConstants.profile, '/user/profile');
      expect(ApiConstants.logout, '/user/auth/logout');
    });

    test('parses notification items', () {
      final json = {
        'success': true,
        'data': {
          'unreadCount': 2,
          'items': [
            {
              '_id': '66f0note0001',
              'title': 'Ride Confirmed',
              'body': 'Your ride is confirmed!',
              'type': 'booking',
              'read': false,
              'createdAt': '2026-09-17T10:28:00.000Z',
            },
          ],
        },
      };
      final items = ApiBody.asMapList(
        ApiBody.dataMap(json)['items'],
      ).map(AppNotification.fromJson).toList();
      expect(items.single.title, 'Ride Confirmed');
      expect(items.single.read, false);
      expect(ApiBody.asInt(ApiBody.dataMap(json)['unreadCount']), 2);
    });

    test('parses wallet balance, order, and transactions', () {
      final wallet = WalletInfo.fromJson({
        'success': true,
        'message': 'Wallet fetched',
        'data': {'walletBalance': 200},
      });
      expect(wallet.hasBalance, true);
      expect(wallet.balance, 200);

      final order = WalletOrder.fromJson({
        'success': true,
        'data': {
          '_id': '6aabe47b87f61528d997cd64',
          'amount': 200,
          'razorpay_order_id': 'order_dev_wallet_6aabe47b87f61528d997cd64',
        },
      });
      expect(order.paymentId, '6aabe47b87f61528d997cd64');
      expect(
        order.razorpayOrderId,
        'order_dev_wallet_6aabe47b87f61528d997cd64',
      );
      expect(order.amountInPaise(200), 20000);

      final withKey = WalletOrder.fromJson({
        'data': {
          '_id': 'pay1',
          'amount': 20000,
          'razorpay_order_id': 'order_EMBFqjDHEEn80l',
          'key': 'rzp_test_123',
        },
      });
      expect(withKey.key, 'rzp_test_123');
      expect(withKey.amountInPaise(200), 20000);

      final nested = WalletOrder.fromJson({
        'success': true,
        'data': {
          'payment': '6aabe47b87f61528d997cd64',
          'order_id': 'order_EMBFqjDHEEn80l',
          'amount': 200,
          'key': 'rzp_test_abc',
        },
      });
      expect(nested.paymentId, '6aabe47b87f61528d997cd64');
      expect(nested.razorpayOrderId, 'order_EMBFqjDHEEn80l');
      expect(nested.key, 'rzp_test_abc');

      final items = ApiBody.dataList({
        'success': true,
        'data': {
          'items': [
            {
              '_id': '6aabe4aa87f61528d997cd75',
              'type': 'credit',
              'amount': 200,
              'balanceAfter': 200,
              'reason': 'wallet_topup',
              'createdAt': '2026-09-17T13:01:30.067Z',
              'title': 'Added Money',
              'subtitle': 'Wallet Recharge',
            },
          ],
        },
      }).map(WalletTransaction.fromJson).toList();
      expect(items.single.isCredit, true);
      expect(items.single.title, 'Added Money');
      expect(items.single.subtitle, 'Wallet Recharge');
      expect(items.single.amountLabel, '+ ₹200.00');
      expect(items.single.balanceLabel, 'Balance: ₹200.00');
    });

    test('parses support ticket and FAQ', () {
      final ticket = SupportTicket.fromJson({
        '_id': '66f0ticket0001',
        'ticketCode': 'SUP-2026-874521',
        'category': 'lost_found',
        'subject': 'Lost & Found Request',
        'message': 'Left a phone in the cab',
        'status': 'open',
        'statusLabel': 'Pending',
        'createdAt': '2026-06-21T14:15:00.000Z',
      });
      expect(ticket.displayCode, 'SUP-2026-874521');
      expect(ticket.status, 'Pending');
      expect(ticket.title, 'Lost & Found Request');

      final faq = FaqItem.fromJson({
        'question': 'How do I book a ride?',
        'answer': 'Set pickup and drop on Home.',
      });
      expect(faq.title, 'How do I book a ride?');
    });

    test('parses saved addresses', () {
      final items = ApiBody.dataList({
        'success': true,
        'data': [
          {
            '_id': '6aabf44387f61528d997d170',
            'label': 'home',
            'name': 'Home',
            'address': '1234, ABC Colony, Near Lal Bagh, Indore',
            'lat': 22.7533,
            'lng': 75.8937,
          },
        ],
      }).map(UserAddress.fromJson).toList();
      expect(items.single.id, '6aabf44387f61528d997d170');
      expect(items.single.labelTitle, AppStrings.labelHome);
      expect(items.single.displayName, 'Home');
      expect(items.single.lat, 22.7533);
      expect(items.single.lng, 75.8937);

      final updated = UserAddress.fromJson({
        '_id': '6aabf44387f61528d997d170',
        'name': 'Office',
        'label': 'work',
        'address': '1234, ABC Colony, Near Lal Bagh, Indore',
        'location': {
          'coordinates': [75.8937, 22.7533],
        },
      });
      expect(updated.labelTitle, AppStrings.labelWork);
      expect(updated.displayName, 'Office');
      expect(updated.lat, 22.7533);
    });

    test('parses place search results with nested lat lng', () {
      final place = PlaceSuggestion.fromApi({
        'address': 'Airport, Indore',
        'city': 'Indore',
        'location': {
          'coordinates': [75.8097, 22.7279],
        },
      });
      expect(place.description, 'Airport, Indore');
      expect(place.hasCoordinates, true);
      expect(place.lat, 22.7279);
      expect(place.lng, 75.8097);
    });

    test('parses user rides list and detail', () {
      final items = ApiBody.dataList({
        'success': true,
        'message': 'Rides fetched',
        'data': {
          'items': [
            {
              '_id': '6aabf58e87f61528d997d1c4',
              'vehicleType': '3-Wheeler',
              'pickup': {
                'address': 'Vijay Nagar, Indore',
                'lat': 22.7533,
                'lng': 75.8937,
              },
              'drop': {
                'address': 'Rajwada, Indore',
                'lat': 22.7196,
                'lng': 75.8577,
              },
              'otp': '1683',
              'status': 'cancelled',
              'distanceKm': 5.26,
              'fare': 43.12,
              'cancelReason': 'No drivers available',
              'bookingId': '2609178758',
              'statusLabel': 'Cancelled',
              'offeredDriver': null,
              'fareBreakdown': {
                'baseFare': 30,
                'tax': 0,
                'discount': 50,
                'total': 43.12,
              },
            },
          ],
          'total': 1,
          'page': 1,
          'limit': 20,
          'pages': 1,
        },
      }).map(RideBooking.fromJson).toList();
      expect(items.single.id, '6aabf58e87f61528d997d1c4');
      expect(items.single.bookingCode, '2609178758');
      expect(items.single.status, RideBookingStatus.cancelled);
      expect(items.single.statusLabel, 'Cancelled');
      expect(items.single.pickup.title, 'Vijay Nagar');
      expect(items.single.drop.routeLine, 'Rajwada, Indore');
      expect(items.single.distance, '5.26 km');
      expect(items.single.vehicleLabel, '3-Wheeler');
      expect(items.single.driver.hasName, false);
      expect(items.single.baseFare, 30);
      expect(items.single.discount, 50);
      expect(items.single.total, 43.12);

      final detail = RideBooking.fromJson({
        'success': true,
        'message': 'Ride fetched',
        'data': {
          '_id': '6aabf58e87f61528d997d1c4',
          'otp': '1683',
          'status': 'cancelled',
          'bookingCode': '2609178758',
          'statusLabel': 'Cancelled',
          'vehicleType': '3-Wheeler',
          'pickup': {'address': 'Vijay Nagar, Indore'},
          'drop': {'address': 'Rajwada, Indore'},
          'distanceKm': 5.26,
          'fareBreakdown': {
            'baseFare': 30,
            'tax': 0,
            'discount': 50,
            'total': 43.12,
          },
        },
      });
      expect(detail.otp, '1683');
      expect(detail.showOtp, false);
      expect(detail.canCancel, false);
    });

    test('parses ride chat messages', () {
      final items = ApiBody.dataList({
        'success': true,
        'message': 'Messages fetched',
        'data': [
          {
            '_id': '6aabf97687f61528d997d32d',
            'ride': '6aabf58e87f61528d997d1c4',
            'fromRole': 'user',
            'from': '6aabd76b382d2c914058c970',
            'text': 'I am at the gate',
            'attachment': '',
            'createdAt': '2026-09-17T14:30:14.818Z',
          },
          {
            '_id': '6aabf97787f61528d997d32e',
            'fromRole': 'driver',
            'text': 'Okay, coming',
            'createdAt': '2026-09-17T14:31:00.000Z',
          },
        ],
      }).map(ChatMessage.fromJson).toList();
      expect(items.first.text, 'I am at the gate');
      expect(items.first.isMine, true);
      expect(items.last.isMine, false);
      expect(items.last.text, 'Okay, coming');
    });

    test('parses ride offers as coupons', () {
      final items = ApiBody.dataList({
        'success': true,
        'message': 'Offers fetched',
        'data': [
          {
            '_id': '6aaba7fc92d59e80a4199f63',
            'code': 'WELCOME50',
            'active': true,
            'description': 'Flat Rs 50 off your first ride',
            'discountType': 'flat',
            'discountValue': 50,
            'maxDiscount': 50,
            'minAmount': 80,
          },
          {
            '_id': '6aaba7fc92d59e80a4199f65',
            'code': 'RIDE10',
            'active': true,
            'description': '10% off city rides',
            'discountType': 'percent',
            'discountValue': 10,
            'maxDiscount': 40,
            'minAmount': 60,
          },
        ],
      }).map(RideCoupon.fromJson).toList();
      expect(items.first.code, 'WELCOME50');
      expect(items.first.subtitle, 'Flat Rs 50 off your first ride');
      expect(items.first.amountOff(200), 50);
      expect(items.last.isPercent, true);
      expect(items.last.amountOff(200), 20);
      expect(items.last.amountOff(500), 40);
    });

    test('parses ride estimate with coupon fare breakdown', () {
      final estimate = RideEstimate.fromJson({
        'success': true,
        'message': 'Estimate fetched',
        'data': {
          'couponCode': 'WELCOME50',
          'fareBreakdown': {
            'baseFare': 30,
            'distanceFare': 63.12,
            'tax': 0,
            'discount': 50,
            'total': 43.12,
          },
        },
      });
      expect(estimate.couponCode, 'WELCOME50');
      expect(estimate.baseFare, 30);
      expect(estimate.discount, 50);
      expect(estimate.total, 43.12);
    });

    test('parses ride estimate vehicle fares', () {
      final estimate = RideEstimate.fromJson({
        'success': true,
        'message': 'Fare estimated',
        'data': [
          {
            'vehicleType': '2-Wheeler',
            'shortName': 'Bike',
            'distanceKm': 5.26,
            'durationMin': 13,
            'fare': 62.08,
            'breakdown': {
              'baseFare': 20,
              'distanceFare': 42.08,
              'tax': 0,
              'discount': 0,
              'total': 62.08,
            },
          },
          {
            'vehicleType': '3-Wheeler',
            'tagline': 'Comfortable Ride',
            'shortName': 'Auto',
            'label': '3-Wheeler (Auto)',
            'distanceKm': 5.26,
            'durationMin': 13,
            'fare': 93.12,
            'breakdown': {
              'baseFare': 30,
              'distanceFare': 63.12,
              'tax': 0,
              'discount': 0,
              'total': 93.12,
            },
          },
        ],
      }, vehicleType: 'Auto');
      expect(estimate.vehicles.length, 2);
      expect(estimate.distance, '5.26 km');
      expect(estimate.total, 93.12);
      expect(estimate.baseFare, 30);
      expect(estimate.vehicles.last.shortName, 'Auto');
      expect(estimate.vehicles.first.displayFare, 62.08);
    });

    test('builds estimate pickup payload from location', () {
      const pickup = RideLocation(
        title: 'Vijay Nagar',
        subtitle: 'Indore, India',
        lat: 22.7533,
        lng: 75.8937,
      );
      expect(pickup.toApiJson(), {
        'address': 'Vijay Nagar, Indore',
        'lat': 22.7533,
        'lng': 75.8937,
      });
      const drop = RideLocation(title: 'Rajwada', subtitle: 'Indore');
      expect(drop.toApiJson(fallbackLat: 22.7196, fallbackLng: 75.8577), {
        'address': 'Rajwada, Indore',
        'lat': 22.7196,
        'lng': 75.8577,
      });
    });

    test('parses ride vehicles for selected category', () {
      final result = RideVehiclesResult.fromJson({
        'success': true,
        'message': 'Vehicles fetched',
        'data': {
          'distanceKm': 28.27,
          'durationMin': 68,
          'distanceLabel': '28 km',
          'pickup': {
            'address': '151, Ward 35, Ratna Lok Colony, Indore',
            'lat': 22.75,
            'lng': 75.89,
          },
          'drop': {
            'address': 'Rajendra Nagar, Indore',
            'lat': 22.71,
            'lng': 75.86,
          },
          'vehicles': [
            {
              'id': '6aaba7fcb46e5ea3da9180cf',
              'category': '3-Wheeler',
              'vehicleType': '3-Wheeler',
              'name': 'Auto',
              'shortName': 'Auto',
              'label': '3-Wheeler (Auto)',
              'tagline': 'Comfortable Ride',
              'fare': 256.16,
              'estimatedDropLabel': 'Drop 9:41 am',
              'breakdown': {
                'baseFare': 30,
                'distanceFare': 226.16,
                'tax': 0,
                'discount': 0,
                'total': 256.16,
              },
            },
          ],
        },
      });
      expect(result.distance, '28 km');
      expect(result.pickup.routeLine, contains('Ratna Lok Colony'));
      expect(result.drop.routeLine, contains('Rajendra Nagar'));
      expect(result.vehicles.single.displayName, 'Auto');
      expect(result.vehicles.single.displayFare, 256.16);
      expect(result.vehicles.single.toOption().badge, 'Drop 9:41 am');
      expect(result.vehicles.single.toOption().price, 256.16);
    });

    test('parses vehicle fare CGST and SGST from breakdown', () {
      final result = RideVehiclesResult.fromJson({
        'success': true,
        'data': {
          'vehicles': [
            {
              'id': '6aaba7fcb46e5ea3da9180cf',
              'name': 'Auto',
              'shortName': 'Auto',
              'fare': 64.88,
              'breakdown': {
                'baseFare': 25,
                'distanceFare': 36.8,
                'waitingCharge': 0,
                'tax': 3.08,
                'cgst': 1.54,
                'sgst': 1.54,
                'igst': 0,
                'discount': 0,
                'total': 64.88,
                'commission': 9.73,
                'platformCommission': 9.73,
                'vendorCommission': 0,
                'driverDeduction': 0,
                'driverEarning': 55.15,
              },
            },
          ],
        },
      });
      final offer = result.vehicles.single;
      expect(offer.baseFare, 25);
      expect(offer.distanceFare, 36.8);
      expect(offer.waitingCharge, 0);
      expect(offer.tax, 3.08);
      expect(offer.cgst, 1.54);
      expect(offer.sgst, 1.54);
      expect(offer.igst, 0);
      expect(offer.total, 64.88);
      final option = offer.toOption();
      expect(option.cgst, 1.54);
      expect(option.sgst, 1.54);
      expect(option.distanceFare, 36.8);
    });

    test('parses create ride response', () {
      final ride = RideBooking.fromJson({
        'success': true,
        'message': 'Ride created',
        'data': {
          '_id': '6aabf58e87f61528d997d1c4',
          'bookingId': '2609178758',
          'status': 'searching',
          'statusLabel': 'Searching',
          'otp': '1683',
          'vehicleType': '3-Wheeler',
          'paymentMethod': 'cash',
          'pickup': {
            'address': 'Vijay Nagar, Indore',
            'lat': 22.7533,
            'lng': 75.8937,
          },
          'drop': {
            'address': 'Rajwada, Indore',
            'lat': 22.7196,
            'lng': 75.8577,
          },
          'fareBreakdown': {
            'baseFare': 30,
            'tax': 0,
            'discount': 50,
            'total': 43.12,
          },
        },
      });
      expect(ride.id, '6aabf58e87f61528d997d1c4');
      expect(ride.bookingCode, '2609178758');
      expect(ride.vehicleLabel, '3-Wheeler');
      expect(ride.paymentLabel, 'cash');
      expect(ride.otp, '1683');
      expect(ride.total, 43.12);
    });

    test('parses nested create ride envelope and live status fields', () {
      final ride = RideBooking.fromJson({
        'success': true,
        'message': 'Ride created',
        'data': {
          'ride': {
            '_id': '66f0ride0001',
            'bookingId': '2405201030',
            'status': 'searching',
            'statusLabel': 'Searching',
            'otp': '0204',
            'vehicleType': '3-Wheeler',
            'etaMinutes': 2,
            'sharePath': '/public/rides/share/a1b2c3d4e5f6',
            'shareToken': 'a1b2c3d4e5f6',
            'couponCode': 'WELCOME50',
            'pickup': {
              'address': 'Vijay Nagar, Indore',
              'lat': 22.7533,
              'lng': 75.8937,
            },
            'drop': {
              'address': 'Dewas, Madhya Pradesh',
              'lat': 22.9623,
              'lng': 76.0508,
            },
            'fareBreakdown': {
              'baseFare': 49,
              'tax': 1,
              'discount': 10,
              'total': 41,
            },
            'driver': null,
            'vehicle': null,
          },
          'payment': null,
        },
      });
      expect(ride.id, '66f0ride0001');
      expect(ride.bookingCode, '2405201030');
      expect(ride.rawStatus, 'searching');
      expect(ride.isSearching, true);
      expect(ride.canCancel, true);
      expect(ride.otp, '0204');
      expect(ride.etaMinutes, 2);
      expect(ride.discount, 10);
      expect(ride.total, 41);
      expect(ride.sharePath, '/public/rides/share/a1b2c3d4e5f6');
    });

    test('parses accepted ride driver, plate, and eta banner', () {
      final ride = RideBooking.fromJson({
        'success': true,
        'data': {
          '_id': '66f0ride0001',
          'bookingId': '2405201030',
          'status': 'accepted',
          'statusLabel': 'On the way',
          'otp': '0204',
          'etaMinutes': 2,
          'distanceKm': 3,
          'vehicleType': '3-Wheeler',
          'driver': {
            'name': 'Ramesh Yadav',
            'phone': '918000000002',
            'rating': 4.8,
            'avatar': '',
          },
          'vehicle': {
            'model': 'Bajaj RE',
            'registrationNumber': 'UP 32 AB 1234',
            'color': 'Yellow',
          },
          'pickup': {'address': 'Vijay Nagar, Indore'},
          'drop': {'address': 'Dewas, Madhya Pradesh'},
        },
      });
      expect(ride.isAssigned, true);
      expect(ride.canCancel, true);
      expect(ride.driver.name, 'Ramesh Yadav');
      expect(ride.driver.vehicleNumber, 'UP 32 AB 1234');
      expect(ride.distance, '03 km');
      expect(ride.etaBanner, 'Driver is on the way, will reach you in 2 mins!');
    });

    test('blocks rider cancel after trip is ongoing', () {
      final ride = RideBooking.fromJson({
        'data': {'_id': '1', 'status': 'ongoing', 'statusLabel': 'Ongoing'},
      });
      expect(ride.status, RideBookingStatus.ongoing);
      expect(ride.canCancel, false);
      expect(ride.isLive, true);
    });

    test('parses apply-coupon fare preview', () {
      final estimate = RideEstimate.fromJson({
        'success': true,
        'data': {
          'couponCode': 'WELCOME50',
          'discount': 10,
          'fare': 41,
          'fareFormatted': '₹41',
          'breakdown': {'baseFare': 49, 'tax': 1, 'discount': 10, 'total': 41},
        },
      }, vehicleType: '3-Wheeler');
      expect(estimate.couponCode, 'WELCOME50');
      expect(estimate.discount, 10);
      expect(estimate.baseFare, 49);
      expect(estimate.tax, 1);
      expect(estimate.total, 41);
    });

    test('parses cancel reasons list', () {
      final items = ApiBody.dataList({
        'success': true,
        'message': 'Cancel reasons fetched',
        'data': [
          {
            'id': '66f0cancel0001',
            'label': 'Driver is taking too long',
            'audience': 'user',
            'sort': 1,
            'active': true,
          },
          {
            'id': '66f0cancel0005',
            'label': 'Other reason',
            'audience': 'user',
            'active': true,
          },
        ],
      });
      expect(items.first['id'], '66f0cancel0001');
      expect(items.last['label'], 'Other reason');
    });

    test('treats active ride null data as no live trip', () {
      final json = {'success': true, 'message': 'No active ride', 'data': null};
      expect(json['data'], isNull);
    });

    test('copies canonical vehicleType onto quote option', () {
      final result = RideVehiclesResult.fromJson({
        'data': {
          'distanceLabel': '03 km',
          'vehicles': [
            {
              'id': '66f0type0003',
              'vehicleType': 'E-Rickshaw',
              'category': '3-Wheeler',
              'name': 'Toto',
              'shortName': 'Toto',
              'tagline': 'Everyday Affordable Ride',
              'fare': 59,
              'estimatedDropLabel': 'Drop 4:38 pm',
              'breakdown': {
                'baseFare': 49,
                'tax': 1,
                'discount': 0,
                'total': 50,
              },
            },
          ],
        },
      });
      final option = result.vehicles.single.toOption();
      expect(option.vehicleType, 'E-Rickshaw');
      expect(option.canonicalType, 'E-Rickshaw');
      expect(option.badge, 'Drop 4:38 pm');
      expect(option.total, 50);
    });

    test('parses unpaid completed ride payment options', () {
      final ride = RideBooking.fromJson({
        'success': true,
        'data': {
          '_id': 'ride1',
          'status': 'completed',
          'paymentStatus': 'pending',
          'paymentMethod': 'cash',
          'paymentLabel': 'Cash',
          'fare': 59,
          'fareBreakdown': {
            'baseFare': 49,
            'tax': 1,
            'discount': 0,
            'total': 59,
          },
          'paymentOptions': [
            {'method': 'cash', 'label': 'Cash', 'available': true},
            {'method': 'online', 'label': 'UPI', 'available': true},
            {
              'method': 'wallet',
              'label': 'Wallet',
              'available': false,
              'walletBalance': 20,
              'shortfall': 39,
            },
          ],
        },
      });
      expect(ride.isCompleted, true);
      expect(ride.isPaid, false);
      expect(ride.isPaymentPending, true);
      expect(ride.paymentMethod, 'cash');
      expect(ride.paymentOptions.length, 3);
      expect(ride.paymentOptions[1].isOnline, true);
      expect(ride.paymentOptions[2].available, false);
      expect(ride.paymentOptions[2].shortfall, 39);
    });

    test('parses ride pay nextStep branches', () {
      final cash = RidePayResult.fromJson({
        'success': true,
        'data': {
          'ride': {
            'paymentMethod': 'cash',
            'paymentLabel': 'Cash',
            'paymentStatus': 'pending',
          },
          'nextStep': 'await_driver_cash',
          'paymentMethod': 'cash',
        },
      });
      expect(cash.awaitCash, true);
      expect(cash.isDone, false);

      final wallet = RidePayResult.fromJson({
        'success': true,
        'data': {
          'ride': {
            'paymentMethod': 'wallet',
            'paymentLabel': 'Wallet',
            'paymentStatus': 'paid',
          },
          'nextStep': 'done',
          'paymentMethod': 'wallet',
        },
      });
      expect(wallet.isDone, true);

      final upi = RidePayResult.fromJson({
        'success': true,
        'data': {
          'nextStep': 'open_razorpay',
          'paymentMethod': 'online',
          'order': {
            'id': 'order_dev_ride_1',
            'amount': 5900,
            'currency': 'INR',
            'keyId': 'rzp_test_1',
            'mock': true,
          },
        },
      });
      expect(upi.openRazorpay, true);
      expect(upi.order?.razorpayOrderId, 'order_dev_ride_1');
      expect(upi.order?.isMock, true);
      expect(upi.order?.key, 'rzp_test_1');
    });

    test('parses CMS page', () {
      final page = CmsPage.fromJson({
        'slug': 'privacy',
        'title': 'Privacy Policy',
        'content': 'We store account, location, and ride data…',
        'updatedAt': '2026-04-01T00:00:00.000Z',
      });
      expect(page.slug, 'privacy');
      expect(page.title, 'Privacy Policy');
    });
  });
}
