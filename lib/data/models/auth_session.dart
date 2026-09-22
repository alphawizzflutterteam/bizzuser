import '../../core/constants/app_strings.dart';
import '../../core/utils/api_body.dart';
import 'sos_alert.dart';

class BankAccount {
  const BankAccount({
    required this.accountName,
    required this.accountNumber,
    required this.ifsc,
    required this.bankName,
    required this.accountType,
  });

  final String accountName;
  final String accountNumber;
  final String ifsc;
  final String bankName;
  final String accountType;

  bool get isEmpty =>
      accountName.isEmpty &&
      accountNumber.isEmpty &&
      ifsc.isEmpty &&
      bankName.isEmpty &&
      accountType.isEmpty;

  String get displayType {
    final value = accountType.trim().toLowerCase();
    if (value == 'current') return AppStrings.currentAccount;
    if (value == 'savings') return AppStrings.savings;
    return accountType;
  }

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountName: json['accountName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ifsc: json['ifsc']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      accountType: json['accountType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'ifsc': ifsc,
      'bankName': bankName,
      'accountType': accountType,
    };
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.avatar,
    required this.city,
    required this.status,
    required this.walletBalance,
    required this.rating,
    required this.referralCode,
    this.ratingCount = 0,
    this.emergencyContacts = const <EmergencyContact>[],
    this.notificationSettings = const {},
    this.bankAccount,
    this.deleteRequested = false,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String avatar;
  final String city;
  final String status;
  final num walletBalance;
  final num rating;
  final num ratingCount;
  final String referralCode;
  final List<EmergencyContact> emergencyContacts;

  bool get hasEmergencyContact =>
      emergencyContacts.any((item) => item.isValid);
  final Map<String, dynamic> notificationSettings;
  final BankAccount? bankAccount;
  final bool deleteRequested;

  factory AuthUser.placeholder() {
    return const AuthUser(
      id: '',
      name: AppStrings.profileUserName,
      phone: '919876543210',
      email: AppStrings.profileUserEmail,
      avatar: '',
      city: 'Indore',
      status: 'active',
      walletBalance: 1250,
      rating: 5,
      referralCode: '',
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final bankMap = ApiBody.asMap(json['bankAccount']);
    return AuthUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      walletBalance: json['walletBalance'] is num
          ? json['walletBalance'] as num
          : num.tryParse(json['walletBalance']?.toString() ?? '') ?? 0,
      rating: json['rating'] is num
          ? json['rating'] as num
          : num.tryParse(json['rating']?.toString() ?? '') ?? 0,
      ratingCount: json['ratingCount'] is num
          ? json['ratingCount'] as num
          : num.tryParse(json['ratingCount']?.toString() ?? '') ?? 0,
      referralCode: (json['referralCode'] ?? json['referCode'])
              ?.toString()
              .trim() ??
          '',
      emergencyContacts: EmergencyContact.listFrom(json['emergencyContacts']),
      notificationSettings: json['notificationSettings'] is Map
          ? Map<String, dynamic>.from(json['notificationSettings'] as Map)
          : const {},
      bankAccount: bankMap == null ? null : BankAccount.fromJson(bankMap),
      deleteRequested: json['deleteRequested'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'city': city,
      'status': status,
      'walletBalance': walletBalance,
      'rating': rating,
      'ratingCount': ratingCount,
      'referralCode': referralCode,
      'emergencyContacts':
          emergencyContacts.map((item) => item.toJson()).toList(),
      'notificationSettings': notificationSettings,
      if (bankAccount != null) 'bankAccount': bankAccount!.toJson(),
      'deleteRequested': deleteRequested,
    };
  }

  AuthUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatar,
    String? city,
    String? status,
    num? walletBalance,
    num? rating,
    num? ratingCount,
    String? referralCode,
    List<EmergencyContact>? emergencyContacts,
    Map<String, dynamic>? notificationSettings,
    BankAccount? bankAccount,
    bool? deleteRequested,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      city: city ?? this.city,
      status: status ?? this.status,
      walletBalance: walletBalance ?? this.walletBalance,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      referralCode: referralCode ?? this.referralCode,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      bankAccount: bankAccount ?? this.bankAccount,
      deleteRequested: deleteRequested ?? this.deleteRequested,
    );
  }
}

class ProfileResult {
  const ProfileResult({required this.message, required this.user});

  final String message;
  final AuthUser user;

  factory ProfileResult.fromJson(
    Map<String, dynamic> json, {
    String fallbackMessage = AppStrings.profileFetched,
  }) {
    final map = ApiBody.dataMap(json);
    final message = (json['message'] as String?)?.trim();
    return ProfileResult(
      message: (message != null && message.isNotEmpty)
          ? message
          : fallbackMessage,
      user: AuthUser.fromJson(map),
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.message,
    required this.token,
    required this.user,
  });

  final String message;
  final String token;
  final AuthUser user;

  factory AuthSession.fromJson(
    Map<String, dynamic> json, {
    String fallbackMessage = AppStrings.loginSuccessful,
  }) {
    final map = ApiBody.dataMap(json);
    final userMap = ApiBody.asMap(map['user']) ?? {};
    final message = (json['message'] as String?)?.trim();

    return AuthSession(
      message: (message != null && message.isNotEmpty)
          ? message
          : fallbackMessage,
      token: map['token']?.toString() ?? '',
      user: AuthUser.fromJson(userMap),
    );
  }
}
