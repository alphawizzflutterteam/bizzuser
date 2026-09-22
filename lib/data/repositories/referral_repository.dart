import '../../core/constants/api_constants.dart';
import '../models/referral_info.dart';
import 'app_config_repository.dart';
import 'base_repository.dart';
import 'profile_repository.dart';

class ReferralRepository extends BaseRepository {
  const ReferralRepository(
    super.apiService, {
    this.profileRepository,
    this.appConfigRepository,
  });

  final ProfileRepository? profileRepository;
  final AppConfigRepository? appConfigRepository;

  Future<ReferralInfo> fetch() async {
    var info = const ReferralInfo();
    try {
      final json = await apiService.getJson(ApiConstants.referral);
      info = ReferralInfo.fromJson(json);
    } catch (_) {}

    var code = info.code.trim();
    if (code.isEmpty) {
      code = profileRepository?.cachedUser()?.referralCode.trim() ?? '';
    }

    var amount = info.rewardAmount;
    if (amount <= 0) {
      final config = appConfigRepository?.cached ??
          await appConfigRepository?.fetch();
      amount = config?.referralRewardAmount ?? 0;
    }

    final history = await _loadHistory(rewardAmount: amount);
    return info.copyWith(
      code: code,
      rewardAmount: amount,
      invitedCount: history.invitedCount > 0
          ? history.invitedCount
          : (info.invitedCount > 0
              ? info.invitedCount
              : history.pending.length + history.rewarded.length),
      earnedAmount: history.earnedAmount > 0
          ? history.earnedAmount
          : info.earnedAmount,
      pendingAmount: history.pendingAmount > 0
          ? history.pendingAmount
          : info.pendingAmount,
      pendingInvites: history.pending,
      rewardedInvites: history.rewarded,
      invites: [...history.pending, ...history.rewarded],
    );
  }

  Future<ReferralHistoryPage> fetchHistory({
    int page = 1,
    int limit = 20,
    String status = '',
  }) async {
    final query = <String, dynamic>{
      'page': '$page',
      'limit': '$limit',
    };
    final value = status.trim();
    if (value.isNotEmpty) query['status'] = value;
    final json = await apiService.getJson(
      ApiConstants.referralHistory,
      query: query,
    );
    return ReferralHistoryPage(
      history: ReferralHistory.fromJson(json),
      status: value,
    );
  }

  Future<
      ({
        List<ReferralInvite> pending,
        List<ReferralInvite> rewarded,
        int invitedCount,
        num earnedAmount,
        num pendingAmount,
      })> _loadHistory({required num rewardAmount}) async {
    final results = await Future.wait([
      _safeHistory(status: 'rewarded'),
      _safeHistory(status: 'pending'),
      _safeHistory(),
    ]);
    final rewarded = results[0];
    final pending = results[1];
    final all = results[2];

    final rewardedItems = rewarded.items.isNotEmpty
        ? rewarded.items
        : all.items.where((item) => item.isRewarded).toList(growable: false);
    final pendingItems = pending.items.isNotEmpty
        ? pending.items
        : all.items.where((item) => item.isPending).toList(growable: false);

    final invited = all.invitedCount > 0
        ? all.invitedCount
        : (all.total > 0 ? all.total : rewarded.total + pending.total);
    final earned = rewarded.earnedAmount > 0
        ? rewarded.earnedAmount
        : _sumAmount(rewardedItems, fallback: rewardAmount);
    final pendingTotal = pending.pendingAmount > 0
        ? pending.pendingAmount
        : _sumAmount(pendingItems, fallback: rewardAmount);

    return (
      pending: pendingItems,
      rewarded: rewardedItems,
      invitedCount: invited > 0
          ? invited
          : pendingItems.length + rewardedItems.length,
      earnedAmount: earned,
      pendingAmount: pendingTotal,
    );
  }

  Future<ReferralHistory> _safeHistory({String status = ''}) async {
    try {
      return (await fetchHistory(status: status)).history;
    } catch (_) {
      return const ReferralHistory();
    }
  }

  num _sumAmount(List<ReferralInvite> items, {required num fallback}) {
    if (items.isEmpty) return 0;
    var total = 0.0;
    for (final item in items) {
      total += item.amount > 0 ? item.amount : fallback;
    }
    return total;
  }
}

class ReferralHistoryPage {
  const ReferralHistoryPage({
    required this.history,
    this.status = '',
  });

  final ReferralHistory history;
  final String status;
}
