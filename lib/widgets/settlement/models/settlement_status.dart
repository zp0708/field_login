/// Settlement status enumeration
enum SettlementStatus {
  /// Settlement is in created state
  created,

  /// Settlement is in unpaid state
  unpaid,
}

/// Extension to provide human-readable labels for settlement status
extension SettlementStatusExtension on SettlementStatus {
  /// Returns the display name for the settlement status
  String get displayName {
    switch (this) {
      case SettlementStatus.created:
        return '创建状态';
      case SettlementStatus.unpaid:
        return '未支付状态';
    }
  }

  /// Returns the appropriate icon for the settlement status
  String get iconName {
    switch (this) {
      case SettlementStatus.created:
        return 'edit';
      case SettlementStatus.unpaid:
        return 'pending_actions';
    }
  }

  /// Returns whether the status allows editing
  bool get canEdit {
    switch (this) {
      case SettlementStatus.created:
        return true;
      case SettlementStatus.unpaid:
        return false;
    }
  }
}
