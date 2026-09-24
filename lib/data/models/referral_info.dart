import '../../core/constants/app_strings.dart';
import '../../core/utils/api_body.dart';
import '../../core/utils/date_format_utils.dart';

class ReferralInvite {
  const ReferralInvite({
    required this.name,
    required this.status,
    this.amount = 0,
    this.date = '',
    this.id = '',
    this.joinedAt = '',
    this.rewardedAt = '',
  });

  final String id;
  final String name;
  final String status;
  final num amount;
  final String date;

  /// Local `dd MMM yyyy, hh:mm a` when the friend signed up.
  final String joinedAt;

  /// Local `dd MMM yyyy, hh:mm a` when the reward was credited (or empty).
  final String rewardedAt;

  /// History row caption: `Joined <date>` / `Rewarded <date>`.
  String get timelineLabel {
    if (isRewarded) {
      final when = rewardedAt.isNotEmpty ? rewardedAt : joinedAt;
      if (when.isNotEmpty) return '${AppStrings.rewardedLabel} $when';
    } else if (joinedAt.isNotEmpty) {
      return '${AppStrings.joinedLabel} $joinedAt';
    }
    return date.isEmpty ? statusLabel : '$statusLabel · $date';
  }

  String get normalizedStatus => status.trim().toLowerCase();

  bool get isRewarded {
    final value = normalizedStatus;
    return value == 'rewarded' ||
        value == 'paid' ||
        value == 'credited' ||
        value.contains('complete');
  }

  bool get isPending {
    final value = normalizedStatus;
    return value.isEmpty ||
        value == 'pending' ||
        value == 'waiting' ||
        value == 'joined' ||
        value.contains('pending');
  }

  String get statusLabel {
    if (isRewarded) return AppStrings.statusRewarded;
    if (isPending) return AppStrings.statusPending;
    if (status.trim().isEmpty) return AppStrings.statusPending;
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  factory ReferralInvite.fromJson(Map<String, dynamic> json) {
    final user = ApiBody.asMap(json['user']) ??
        ApiBody.asMap(json['invitee']) ??
        ApiBody.asMap(json['referredUser']) ??
        ApiBody.asMap(json['friend']) ??
        const <String, dynamic>{};
    final name = (json['name'] ??
            json['fullName'] ??
            user['name'] ??
            json['phone'] ??
            user['phone'] ??
            json['email'] ??
            user['email'] ??
            '')
        .toString()
        .trim();
    return ReferralInvite(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: name,
      status: (json['status'] ?? json['state'] ?? json['rewardStatus'] ?? '')
          .toString()
          .trim(),
      amount: ApiBody.asNum(
        json['amount'] ??
            json['rewardAmount'] ??
            json['earnedAmount'] ??
            json['reward'],
      ),
      date: DateFormatUtils.walletDate(
        (json['rewardedAt'] ??
                json['completedAt'] ??
                json['joinedAt'] ??
                json['createdAt'] ??
                json['updatedAt'])
            ?.toString(),
        fallback: '',
      ),
      joinedAt: DateFormatUtils.dateTime(
        (json['joinedAt'] ?? json['createdAt'])?.toString(),
      ),
      rewardedAt: DateFormatUtils.dateTime(
        (json['rewardedAt'] ?? json['completedAt'])?.toString(),
      ),
    );
  }
}

class ReferralHistory {
  const ReferralHistory({
    this.items = const [],
    this.total = 0,
    this.earnedAmount = 0,
    this.pendingAmount = 0,
    this.invitedCount = 0,
  });

  final List<ReferralInvite> items;
  final int total;
  final num earnedAmount;
  final num pendingAmount;
  final int invitedCount;

  factory ReferralHistory.fromJson(Map<String, dynamic> json) {
    final data = ApiBody.dataMap(json);
    final source = data.isNotEmpty ? data : json;
    final summary = ApiBody.asMap(source['summary']) ??
        ApiBody.asMap(source['stats']) ??
        ApiBody.asMap(json['summary']) ??
        const <String, dynamic>{};
    final pagination = ApiBody.asMap(source['pagination']) ??
        ApiBody.asMap(json['pagination']) ??
        const <String, dynamic>{};

    var rows = <Map<String, dynamic>>[];
    for (final raw in [
      source['items'],
      source['history'],
      source['referrals'],
      source['list'],
      source['records'],
      source['docs'],
      json['data'],
      json['items'],
    ]) {
      rows = ApiBody.asMapList(raw);
      if (rows.isNotEmpty) break;
    }

    final items = rows
        .map(ReferralInvite.fromJson)
        .where((item) => item.name.isNotEmpty || item.status.isNotEmpty)
        .toList(growable: false);

    final total = ApiBody.asInt(
          source['total'] ??
              source['totalDocs'] ??
              pagination['total'] ??
              pagination['totalDocs'] ??
              summary['total'] ??
              summary['invitedCount'] ??
              source['invitedCount'] ??
              json['total'] ??
              items.length,
        ) ??
        items.length;

    return ReferralHistory(
      items: items,
      total: total,
      invitedCount: ApiBody.asInt(
            summary['invitedCount'] ??
                summary['invited'] ??
                source['invitedCount'] ??
                total,
          ) ??
          total,
      earnedAmount: ApiBody.asNum(
        summary['earnedAmount'] ??
            summary['totalEarned'] ??
            summary['earned'] ??
            source['earnedAmount'] ??
            source['totalEarned'],
      ),
      pendingAmount: ApiBody.asNum(
        summary['pendingAmount'] ??
            summary['pending'] ??
            source['pendingAmount'],
      ),
    );
  }
}

class ReferralInfo {
  const ReferralInfo({
    this.code = '',
    this.rewardAmount = 0,
    this.shareUrl = '',
    this.shareText = '',
    this.invitedCount = 0,
    this.earnedAmount = 0,
    this.pendingAmount = 0,
    this.invites = const [],
    this.pendingInvites = const [],
    this.rewardedInvites = const [],
  });

  final String code;
  final num rewardAmount;
  final String shareUrl;
  final String shareText;
  final int invitedCount;
  final num earnedAmount;
  final num pendingAmount;
  final List<ReferralInvite> invites;
  final List<ReferralInvite> pendingInvites;
  final List<ReferralInvite> rewardedInvites;

  ReferralInfo copyWith({
    String? code,
    num? rewardAmount,
    String? shareUrl,
    String? shareText,
    int? invitedCount,
    num? earnedAmount,
    num? pendingAmount,
    List<ReferralInvite>? invites,
    List<ReferralInvite>? pendingInvites,
    List<ReferralInvite>? rewardedInvites,
  }) {
    return ReferralInfo(
      code: code ?? this.code,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      shareUrl: shareUrl ?? this.shareUrl,
      shareText: shareText ?? this.shareText,
      invitedCount: invitedCount ?? this.invitedCount,
      earnedAmount: earnedAmount ?? this.earnedAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      invites: invites ?? this.invites,
      pendingInvites: pendingInvites ?? this.pendingInvites,
      rewardedInvites: rewardedInvites ?? this.rewardedInvites,
    );
  }

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    final data = ApiBody.dataMap(json);
    final source = data.isNotEmpty ? data : json;
    final nested = ApiBody.asMap(source['referral']) ?? source;
    final rows = ApiBody.asMapList(
      nested['referrals'] ??
          nested['invites'] ??
          nested['invitees'] ??
          nested['friends'] ??
          source['referrals'],
    );
    final invites = rows
        .map(ReferralInvite.fromJson)
        .where((item) => item.name.isNotEmpty || item.status.isNotEmpty)
        .toList(growable: false);

    return ReferralInfo(
      code: (nested['referralCode'] ??
              nested['code'] ??
              source['referralCode'] ??
              source['code'] ??
              '')
          .toString()
          .trim(),
      rewardAmount: ApiBody.asNum(
        nested['referralRewardAmount'] ??
            nested['rewardAmount'] ??
            nested['amount'] ??
            source['referralRewardAmount'] ??
            source['rewardAmount'],
      ),
      shareUrl: (nested['shareUrl'] ??
              nested['inviteUrl'] ??
              nested['link'] ??
              source['shareUrl'] ??
              '')
          .toString()
          .trim(),
      shareText: (nested['shareText'] ??
              nested['shareMessage'] ??
              nested['message'] ??
              source['shareText'] ??
              '')
          .toString()
          .trim(),
      invitedCount: ApiBody.asInt(
            nested['invitedCount'] ??
                nested['totalReferrals'] ??
                nested['referralCount'] ??
                nested['invited'] ??
                source['invitedCount'] ??
                invites.length,
          ) ??
          invites.length,
      earnedAmount: ApiBody.asNum(
        nested['earnedAmount'] ??
            nested['totalEarned'] ??
            nested['earned'] ??
            source['earnedAmount'],
      ),
      pendingAmount: ApiBody.asNum(
        nested['pendingAmount'] ?? nested['pending'] ?? source['pendingAmount'],
      ),
      invites: invites,
      pendingInvites: invites.where((item) => item.isPending).toList(),
      rewardedInvites: invites.where((item) => item.isRewarded).toList(),
    );
  }
}
