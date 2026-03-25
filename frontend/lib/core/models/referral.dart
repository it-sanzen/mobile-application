enum ReferralStatus {
  pending('PENDING'),
  verified('VERIFIED'),
  rewardApplied('REWARD_APPLIED'),
  rejected('REJECTED');

  final String value;
  const ReferralStatus(this.value);

  String get label {
    switch (this) {
      case ReferralStatus.pending:
        return 'Pending';
      case ReferralStatus.verified:
        return 'Verified';
      case ReferralStatus.rewardApplied:
        return 'Reward Applied';
      case ReferralStatus.rejected:
        return 'Rejected';
    }
  }

  static ReferralStatus fromString(String value) {
    return ReferralStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ReferralStatus.pending,
    );
  }
}

class ReferralCodeModel {
  final String id;
  final String userId;
  final String code;
  final DateTime createdAt;

  ReferralCodeModel({
    required this.id,
    required this.userId,
    required this.code,
    required this.createdAt,
  });

  factory ReferralCodeModel.fromJson(Map<String, dynamic> json) {
    return ReferralCodeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      code: json['code'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ReferralModel {
  final String id;
  final String referrerId;
  final String referralCodeId;
  final String referredName;
  final String referredPhone;
  final String? referredEmail;
  final ReferralStatus status;
  final double rewardAmount;
  final int? appliedToInstallment;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referralCodeId,
    required this.referredName,
    required this.referredPhone,
    this.referredEmail,
    required this.status,
    required this.rewardAmount,
    this.appliedToInstallment,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] as String,
      referrerId: json['referrerId'] as String,
      referralCodeId: json['referralCodeId'] as String,
      referredName: json['referredName'] as String,
      referredPhone: json['referredPhone'] as String,
      referredEmail: json['referredEmail'] as String?,
      status: ReferralStatus.fromString(json['status'] as String),
      rewardAmount: (json['rewardAmount'] as num).toDouble(),
      appliedToInstallment: json['appliedToInstallment'] as int?,
      adminNotes: json['adminNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ReferralDashboard {
  final String referralCode;
  final int totalReferrals;
  final int pending;
  final int verified;
  final int rewardApplied;
  final int rejected;
  final double totalRewardsEarned;
  final List<ReferralModel> referrals;

  ReferralDashboard({
    required this.referralCode,
    required this.totalReferrals,
    required this.pending,
    required this.verified,
    required this.rewardApplied,
    required this.rejected,
    required this.totalRewardsEarned,
    required this.referrals,
  });

  factory ReferralDashboard.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final referralsList = (json['referrals'] as List)
        .map((r) => ReferralModel.fromJson(r as Map<String, dynamic>))
        .toList();

    return ReferralDashboard(
      referralCode: json['referralCode'] as String,
      totalReferrals: stats['totalReferrals'] as int,
      pending: stats['pending'] as int,
      verified: stats['verified'] as int,
      rewardApplied: stats['rewardApplied'] as int,
      rejected: stats['rejected'] as int,
      totalRewardsEarned: (stats['totalRewardsEarned'] as num).toDouble(),
      referrals: referralsList,
    );
  }
}
