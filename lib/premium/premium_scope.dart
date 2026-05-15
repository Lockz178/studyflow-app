import 'package:flutter/widgets.dart';

import 'premium_controller.dart';

class PremiumScope extends InheritedNotifier<PremiumController> {
  const PremiumScope({
    super.key,
    required PremiumController controller,
    required super.child,
  }) : super(notifier: controller);

  static PremiumController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PremiumScope>();
    assert(scope != null, 'PremiumScope not found in widget tree');
    return scope!.notifier!;
  }

  static PremiumController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PremiumScope>()?.notifier;
  }
}

