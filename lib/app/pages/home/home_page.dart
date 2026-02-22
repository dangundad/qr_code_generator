import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:qr_code_generator/app/admob/ads_banner.dart';
import 'package:qr_code_generator/app/admob/ads_helper.dart';
import 'package:qr_code_generator/app/controllers/qr_controller.dart';
import 'package:qr_code_generator/app/data/enums/qr_type.dart';

class HomePage extends GetView<QrController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('app_name'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => _showHistorySheet(context),
            tooltip: 'history'.tr,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  children: [
                    // Type selector
                    _TypeSelector(ctrl: controller),
                    SizedBox(height: 16.h),
                    // Form
                    Obx(() => _buildForm(controller.qrType.value)),
                    SizedBox(height: 20.h),
                    // QR Preview
                    _QrPreview(ctrl: controller),
                    SizedBox(height: 16.h),
                    // Color palette
                    _ColorPicker(ctrl: controller),
                    SizedBox(height: 20.h),
                    // Action buttons
                    _ActionBar(ctrl: controller),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            BannerAdWidget(
              adUnitId: AdHelper.bannerAdUnitId,
              type: AdHelper.banner,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(QrType type) {
    return switch (type) {
      QrType.url => _UrlForm(ctrl: controller),
      QrType.text => _TextForm(ctrl: controller),
      QrType.wifi => _WifiForm(ctrl: controller),
      QrType.contact => _ContactForm(ctrl: controller),
      QrType.email => _EmailForm(ctrl: controller),
    };
  }

  void _showHistorySheet(BuildContext context) {
    Get.bottomSheet(
      _HistorySheet(ctrl: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ─── Type Selector ────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final QrController ctrl;
  const _TypeSelector({required this.ctrl});

  static const _types = [
    (QrType.url, '🔗', 'URL'),
    (QrType.text, '📝', 'Text'),
    (QrType.wifi, '📶', 'WiFi'),
    (QrType.contact, '👤', 'Contact'),
    (QrType.email, '✉️', 'Email'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      return SizedBox(
        height: 64.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _types.length,
          separatorBuilder: (context, index) => SizedBox(width: 8.w),
          itemBuilder: (ctx, i) {
            final (type, icon, label) = _types[i];
            final selected = ctrl.qrType.value == type;
            return GestureDetector(
              onTap: () {
                ctrl.qrType.value = type;
                ctrl.clearForm();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: selected ? cs.primaryContainer : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: selected ? cs.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(icon, style: TextStyle(fontSize: 18.sp)),
                    SizedBox(height: 2.h),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? cs.primary : cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ─── QR Preview ───────────────────────────────────────────

class _QrPreview extends StatelessWidget {
  final QrController ctrl;
  const _QrPreview({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final data = ctrl.qrData.value;
      final fg = Color(ctrl.fgColor.value);
      final bg = Color(ctrl.bgColor.value);

      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            if (data.isEmpty)
              SizedBox(
                width: 180.r,
                height: 180.r,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 64.r,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'fill_form'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              RepaintBoundary(
                key: ctrl.qrKey,
                child: Container(
                  color: bg,
                  padding: EdgeInsets.all(8.r),
                  child: QrImageView(
                    data: data,
                    version: QrVersions.auto,
                    size: 180.r,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: fg,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: fg,
                    ),
                    backgroundColor: bg,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ─── Color Picker ─────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  final QrController ctrl;
  const _ColorPicker({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'fg_color'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: QrController.fgColorOptions.map((c) {
                    final selected = ctrl.fgColor.value == c;
                    return GestureDetector(
                      onTap: () => ctrl.fgColor.value = c,
                      child: Container(
                        width: 28.r,
                        height: 28.r,
                        margin: EdgeInsets.only(right: 6.w),
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? cs.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'bg_color'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: QrController.bgColorOptions.map((c) {
                    final selected = ctrl.bgColor.value == c;
                    return GestureDetector(
                      onTap: () => ctrl.bgColor.value = c,
                      child: Container(
                        width: 28.r,
                        height: 28.r,
                        margin: EdgeInsets.only(right: 6.w),
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? cs.primary : cs.outline,
                            width: selected ? 3 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ─── Action Bar ───────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final QrController ctrl;
  const _ActionBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasData = ctrl.qrData.value.isNotEmpty;
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: hasData ? ctrl.shareQr : null,
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(
                'share'.tr,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          OutlinedButton.icon(
            onPressed: hasData ? ctrl.copyContent : null,
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text('copy'.tr, style: TextStyle(fontSize: 13.sp)),
          ),
          SizedBox(width: 10.w),
          OutlinedButton(
            onPressed: ctrl.clearForm,
            child: const Icon(Icons.refresh_rounded, size: 18),
          ),
        ],
      );
    });
  }
}

// ─── Form Widgets ─────────────────────────────────────────

class _UrlForm extends StatelessWidget {
  final QrController ctrl;
  const _UrlForm({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      children: [
        _Field(
          ctrl: ctrl.urlCtrl,
          label: 'url_label'.tr,
          hint: 'https://example.com',
          icon: Icons.link_rounded,
          keyboard: TextInputType.url,
        ),
      ],
    );
  }
}

class _TextForm extends StatelessWidget {
  final QrController ctrl;
  const _TextForm({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      children: [
        _Field(
          ctrl: ctrl.textCtrl,
          label: 'text_label'.tr,
          hint: 'text_hint'.tr,
          icon: Icons.text_fields_rounded,
          maxLines: 4,
        ),
      ],
    );
  }
}

class _WifiForm extends StatelessWidget {
  final QrController ctrl;
  const _WifiForm({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _FormCard(
      children: [
        _Field(
          ctrl: ctrl.wifiSsidCtrl,
          label: 'wifi_ssid'.tr,
          hint: 'MyNetwork',
          icon: Icons.wifi_rounded,
        ),
        SizedBox(height: 12.h),
        _Field(
          ctrl: ctrl.wifiPasswordCtrl,
          label: 'wifi_password'.tr,
          hint: '••••••••',
          icon: Icons.lock_rounded,
          obscure: true,
        ),
        SizedBox(height: 12.h),
        Text(
          'wifi_security'.tr,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(() {
          return Row(
            children: ['WPA', 'WEP', 'nopass'].map((s) {
              final sel = ctrl.wifiSecurity.value == s;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ChoiceChip(
                  label: Text(s),
                  selected: sel,
                  onSelected: (_) => ctrl.wifiSecurity.value = s,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _ContactForm extends StatelessWidget {
  final QrController ctrl;
  const _ContactForm({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      children: [
        _Field(
          ctrl: ctrl.contactNameCtrl,
          label: 'contact_name'.tr,
          hint: 'John Doe',
          icon: Icons.person_rounded,
        ),
        SizedBox(height: 12.h),
        _Field(
          ctrl: ctrl.contactPhoneCtrl,
          label: 'contact_phone'.tr,
          hint: '+1 234 567 8900',
          icon: Icons.phone_rounded,
          keyboard: TextInputType.phone,
        ),
        SizedBox(height: 12.h),
        _Field(
          ctrl: ctrl.contactEmailCtrl,
          label: 'contact_email'.tr,
          hint: 'john@example.com',
          icon: Icons.email_rounded,
          keyboard: TextInputType.emailAddress,
        ),
        SizedBox(height: 12.h),
        _Field(
          ctrl: ctrl.contactOrgCtrl,
          label: 'contact_org'.tr,
          hint: 'Company Inc.',
          icon: Icons.business_rounded,
        ),
      ],
    );
  }
}

class _EmailForm extends StatelessWidget {
  final QrController ctrl;
  const _EmailForm({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      children: [
        _Field(
          ctrl: ctrl.emailAddressCtrl,
          label: 'email_to'.tr,
          hint: 'email@example.com',
          icon: Icons.email_rounded,
          keyboard: TextInputType.emailAddress,
        ),
        SizedBox(height: 12.h),
        _Field(
          ctrl: ctrl.emailSubjectCtrl,
          label: 'email_subject'.tr,
          hint: 'email_subject_hint'.tr,
          icon: Icons.subject_rounded,
        ),
        SizedBox(height: 12.h),
        _Field(
          ctrl: ctrl.emailBodyCtrl,
          label: 'email_body'.tr,
          hint: 'email_body_hint'.tr,
          icon: Icons.message_rounded,
          maxLines: 3,
        ),
      ],
    );
  }
}

// ─── Reusable Field Widget ────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;
  final bool obscure;
  final int maxLines;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.obscure = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: obscure,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18.r),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      ),
    );
  }
}

// ─── Form Card ────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ─── History Sheet ────────────────────────────────────────

class _HistorySheet extends StatelessWidget {
  final QrController ctrl;
  const _HistorySheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        top: 12.h,
        left: 16.w,
        right: 16.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                'history'.tr,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Obx(() {
                if (ctrl.history.isEmpty) return const SizedBox.shrink();
                return TextButton(
                  onPressed: ctrl.clearHistory,
                  child: Text(
                    'clear_all'.tr,
                    style: TextStyle(color: cs.error),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(() {
            if (ctrl.history.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Text(
                  'no_history'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              );
            }
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 400.h),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: ctrl.history.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final entry = ctrl.history[i];
                  final type = entry['type'] ?? 'url';
                  final label = entry['label'] ?? '';
                  return ListTile(
                    leading: _typeIcon(type),
                    title: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: cs.primary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_rounded, color: cs.error, size: 18.r),
                      onPressed: () => ctrl.deleteHistory(i),
                    ),
                    onTap: () {
                      ctrl.loadFromHistory(entry);
                      Get.back();
                    },
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _typeIcon(String type) {
    final icons = {
      'url': '🔗',
      'text': '📝',
      'wifi': '📶',
      'contact': '👤',
      'email': '✉️',
    };
    return Text(icons[type] ?? '📋', style: const TextStyle(fontSize: 24));
  }
}
