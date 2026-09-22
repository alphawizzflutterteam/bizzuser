import '../../core/utils/api_body.dart';
import '../../core/utils/date_format_utils.dart';
import '../../core/utils/media_url.dart';

class EmergencyContact {
  const EmergencyContact({this.name = '', this.phone = ''});

  final String name;
  final String phone;

  bool get isValid => phone.trim().isNotEmpty;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: (json['name'] ?? json['fullName'] ?? '').toString().trim(),
      phone: (json['phone'] ?? json['mobile'] ?? json['number'] ?? '')
          .toString()
          .trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'phone': phone.trim(),
    };
  }

  static List<EmergencyContact> listFrom(dynamic raw) {
    return ApiBody.asMapList(raw)
        .map(EmergencyContact.fromJson)
        .where((item) => item.name.isNotEmpty || item.phone.isNotEmpty)
        .toList();
  }
}

class SosNotifiedContact {
  const SosNotifiedContact({
    this.name = '',
    this.phone = '',
    this.smsStatus = '',
    this.smsError = '',
  });

  final String name;
  final String phone;
  final String smsStatus;
  final String smsError;

  factory SosNotifiedContact.fromJson(Map<String, dynamic> json) {
    return SosNotifiedContact(
      name: (json['name'] ?? '').toString().trim(),
      phone: (json['phone'] ?? '').toString().trim(),
      smsStatus: (json['smsStatus'] ?? '').toString().trim(),
      smsError: (json['smsError'] ?? '').toString().trim(),
    );
  }
}

class SosAlert {
  const SosAlert({
    this.id = '',
    this.status = '',
    this.raisedBy = '',
    this.message = '',
    this.lat = 0,
    this.lng = 0,
    this.rideId = '',
    this.location = '',
    this.sharePath = '',
    this.shareUrl = '',
    this.mapsUrl = '',
    this.sosNumbers = const [],
    this.emergencyContacts = const [],
    this.contactsNotified = const [],
    this.createdAt = '',
  });

  final String id;
  final String status;
  final String raisedBy;
  final String message;
  final double lat;
  final double lng;
  final String rideId;
  final String location;
  final String sharePath;
  final String shareUrl;
  final String mapsUrl;
  final List<String> sosNumbers;
  final List<EmergencyContact> emergencyContacts;
  final List<SosNotifiedContact> contactsNotified;
  final String createdAt;

  bool get isOpen => status.trim().toLowerCase() == 'open';

  String get displayShareUrl {
    if (shareUrl.trim().isNotEmpty) return shareUrl.trim();
    if (sharePath.trim().isNotEmpty) return MediaUrl.resolve(sharePath);
    return '';
  }

  String get displayMapsUrl {
    if (mapsUrl.trim().isNotEmpty) return mapsUrl.trim();
    if (lat == 0 && lng == 0) return '';
    return 'https://www.google.com/maps?q=$lat,$lng';
  }

  String get timeLabel =>
      DateFormatUtils.relative(createdAt, fallback: createdAt);

  String get shareText {
    final maps = displayMapsUrl;
    final live = displayShareUrl;
    return 'Emergency: I need help. Location: $maps Live trip: $live';
  }

  factory SosAlert.fromJson(Map<String, dynamic> json) {
    final data = ApiBody.dataMap(json);
    final source = data.isNotEmpty ? data : json;
    final numbers = <String>[];
    final rawNumbers = source['sosNumbers'];
    if (rawNumbers is List) {
      for (final item in rawNumbers) {
        if (item is String && item.trim().isNotEmpty) {
          numbers.add(item.trim());
        } else if (item is Map) {
          final value =
              (item['phone'] ?? item['number'] ?? item['value'] ?? '')
                  .toString()
                  .trim();
          if (value.isNotEmpty) numbers.add(value);
        }
      }
    }
    return SosAlert(
      id: (source['_id'] ?? source['id'] ?? '').toString(),
      status: (source['status'] ?? '').toString().trim(),
      raisedBy: (source['raisedBy'] ?? '').toString().trim(),
      message: (source['message'] ?? '').toString().trim(),
      lat: ApiBody.asNum(source['lat']).toDouble(),
      lng: ApiBody.asNum(source['lng']).toDouble(),
      rideId: _rideIdOf(source),
      location: (source['location'] ?? source['address'] ?? '')
          .toString()
          .trim(),
      sharePath: (source['sharePath'] ?? '').toString().trim(),
      shareUrl: (source['shareUrl'] ?? '').toString().trim(),
      mapsUrl: (source['mapsUrl'] ?? '').toString().trim(),
      sosNumbers: numbers.toSet().toList(growable: false),
      emergencyContacts: EmergencyContact.listFrom(source['emergencyContacts']),
      contactsNotified: ApiBody.asMapList(source['contactsNotified'])
          .map(SosNotifiedContact.fromJson)
          .toList(growable: false),
      createdAt: (source['createdAt'] ?? source['updatedAt'] ?? '')
          .toString()
          .trim(),
    );
  }

  static String _rideIdOf(Map<String, dynamic> source) {
    final raw = source['rideId'] ?? source['ride'];
    if (raw is Map) {
      return (raw['_id'] ?? raw['id'] ?? '').toString().trim();
    }
    return (raw ?? '').toString().trim();
  }
}

class SosHistoryPage {
  const SosHistoryPage({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 20,
    this.pages = 1,
  });

  final List<SosAlert> items;
  final int total;
  final int page;
  final int limit;
  final int pages;

  factory SosHistoryPage.fromJson(Map<String, dynamic> json) {
    final data = ApiBody.dataMap(json);
    final source = data.isNotEmpty ? data : json;
    var rows = ApiBody.dataList(json);
    if (rows.isEmpty) {
      rows = ApiBody.asMapList(source['items'] ?? source['history']);
    }
    return SosHistoryPage(
      items: rows.map(SosAlert.fromJson).toList(growable: false),
      total: ApiBody.asInt(source['total']) ?? rows.length,
      page: ApiBody.asInt(source['page']) ?? 1,
      limit: ApiBody.asInt(source['limit']) ?? 20,
      pages: ApiBody.asInt(source['pages']) ?? 1,
    );
  }
}
