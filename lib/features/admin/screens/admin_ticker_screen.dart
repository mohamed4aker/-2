import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/product_image.dart';
import '../../products/widgets/ticker_bar.dart';
import '../../settings/data/models/ticker_item.dart';
import '../../settings/providers/settings_provider.dart';

/// إدارة محتوى الشريط المتحرك: نصوص وصور، ترتيب وتفعيل/إيقاف كل عنصر.
class AdminTickerScreen extends StatelessWidget {
  const AdminTickerScreen({super.key});

  Future<void> _addText(BuildContext context, {TickerItem? existing}) async {
    final controller = TextEditingController(text: existing?.value ?? '');
    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(existing == null ? 'نص جديد' : 'تعديل النص'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'اكتب الجملة اللي هتظهر في الشريط...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.of(dialogContext).pop(value);
            },
            child: const Text(
              'حفظ',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (text == null || !context.mounted) return;
    final provider = context.read<SettingsProvider>();
    if (existing == null) {
      await provider.addTickerItem(TickerType.text, text);
    } else {
      await provider.updateTickerItem(existing.id, value: text);
    }
  }

  Future<void> _addImage(BuildContext context) async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !context.mounted) return;
    await context
        .read<SettingsProvider>()
        .addTickerItem(TickerType.image, picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final items = provider.settings.tickerItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('محتوى الشريط'),
        actions: [
          IconButton(
            tooltip: 'إضافة صورة',
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () => _addImage(context),
          ),
          IconButton(
            tooltip: 'إضافة نص',
            icon: const Icon(Icons.text_fields),
            onPressed: () => _addText(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // معاينة حية للشريط
          Container(
            width: double.infinity,
            color: AppTheme.lightGrey,
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                const Text(
                  'معاينة',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const TickerBar(),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const EmptyView(
                    icon: Icons.campaign_outlined,
                    title: 'الشريط فاضي',
                    subtitle: 'أضف نص أو صورة من الأزرار فوق',
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    onReorder: provider.reorderTicker,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        key: ValueKey(item.id),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: item.type == TickerType.image
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: ProductImage(
                                    path: item.value,
                                    width: 48,
                                    height: 48,
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.text_fields,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                          title: Text(
                            item.type == TickerType.image
                                ? 'صورة'
                                : item.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: item.enabled
                                  ? Colors.black
                                  : Colors.black38,
                            ),
                          ),
                          subtitle: Text(
                            item.enabled ? 'ظاهر' : 'متوقف',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: item.enabled,
                                activeColor: Colors.black,
                                onChanged: (v) => provider.updateTickerItem(
                                  item.id,
                                  enabled: v,
                                ),
                              ),
                              if (item.type == TickerType.text)
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () =>
                                      _addText(context, existing: item),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    provider.removeTickerItem(item.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
