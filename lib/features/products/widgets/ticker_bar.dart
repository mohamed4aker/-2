import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/product_image.dart';
import '../../settings/data/models/ticker_item.dart';
import '../../settings/providers/settings_provider.dart';

/// الشريط المتحرك اللي بيلف في أعلى الصفحة الرئيسية.
///
/// كل لفة بيعرض عنصر: إما نص كتبه صاحب المتجر أو صورة اختارها.
/// يتحكم فيه صاحب المتجر من: لوحة التحكم ← الإعدادات ← الشريط المتحرك.
class TickerBar extends StatefulWidget {
  const TickerBar({super.key});

  @override
  State<TickerBar> createState() => _TickerBarState();
}

class _TickerBarState extends State<TickerBar> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restartTimer(int count, int seconds) {
    _timer?.cancel();
    if (count <= 1) return;
    _timer = Timer.periodic(Duration(seconds: seconds), (_) {
      if (!mounted || !_controller.hasClients) return;
      _page = (_page + 1) % count;
      _controller.animateToPage(
        _page,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    if (!settings.tickerEnabled) return const SizedBox.shrink();

    final items = settings.activeTickerItems;
    if (items.isEmpty) return const SizedBox.shrink();

    // إعادة ضبط المؤقت لو عدد العناصر أو السرعة اتغيرت.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _restartTimer(items.length, settings.tickerSpeed);
    });

    final hasImage = items.any((i) => i.type == TickerType.image);

    return Container(
      height: hasImage ? 90 : 40,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.black,
      child: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        onPageChanged: (i) => _page = i,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item.type == TickerType.image) {
            return ProductImage(path: item.value, fit: BoxFit.cover);
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                item.value,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
