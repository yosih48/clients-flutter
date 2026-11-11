import 'package:clientsf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Service types are stored in Firestore by their Hebrew key; these helpers
/// turn a stored key into a translated label and an icon.
const String serviceRemote = 'טיפול מרחוק';
const String serviceEquipmentSale = 'מכירת ציוד';
const String serviceAtClient = 'בית הלקוח';

String serviceTypeLabel(AppLocalizations loc, String? key) {
  switch (key) {
    case serviceRemote:
      return loc.serviceRemote;
    case serviceEquipmentSale:
      return loc.serviceEquipmentSale;
    case serviceAtClient:
      return loc.serviceAtClient;
    default:
      return key ?? '';
  }
}

IconData serviceTypeIcon(String? key) {
  switch (key) {
    case serviceRemote:
      return Icons.headset_mic_rounded;
    case serviceEquipmentSale:
      return Icons.shopping_bag_rounded;
    case serviceAtClient:
      return Icons.home_work_rounded;
    default:
      return Icons.handyman_outlined;
  }
}
