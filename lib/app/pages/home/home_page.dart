import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:qr_code_generator/app/admob/ads_banner.dart';
import 'package:qr_code_generator/app/admob/ads_helper.dart';
import 'package:qr_code_generator/app/routes/app_pages.dart';
import 'package:qr_code_generator/app/controllers/qr_controller.dart';
import 'package:qr_code_generator/app/data/enums/qr_type.dart';

class HomePage extends GetView<QrController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withValues(alpha: 0.12),
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.16),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                child: _Header(
                  cs: cs,
                  onHistory: () => _showHistorySheet(context),
                  onGuide: () => Get.toNamed(Routes.GUIDE),
                  onSettings: () => Get.toNamed(Routes.SETTINGS),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: Column(
                    children: [
                      _TypeSelector(ctrl: controller),
                      SizedBox(height: 14.h),
                      Obx(() {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: KeyedSubtree(
                            key: ValueKey(controller.qrType.value),
                            child: _buildForm(controller.qrType.value),
                          ),
                        );
                      }),
                      SizedBox(height: 18.h),
                      _QrPreview(ctrl: controller),
                      SizedBox(height: 16.h),
                      _ColorPicker(ctrl: controller),
                      SizedBox(height: 18.h),
                      _ActionBar(ctrl: controller),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              Container(
                color: cs.surface.withValues(alpha: 0.9),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      top: 8.h,
                      bottom: 10.h,
                    ),
                    child: BannerAdWidget(
                      adUnitId: AdHelper.bannerAdUnitId,
                      type: AdHelper.banner,
                    ),
                  ),
                ),
              ),
            ],
          ),
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

class _Header extends StatelessWidget {
  final ColorScheme cs;
  final VoidCallback onHistory;
  final VoidCallback onGuide;
  final VoidCallback onSettings;

  const _Header({
    required this.cs,
    required this.onHistory,
    required this.onGuide,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1),
            duration: const Duration(milliseconds: 680),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Transform.scale(scale: value, child: child),
            child: Text('📱', style: TextStyle(fontSize: 30.sp)),
          ),
          SizedBox(width: 10.w),
          Text(
            'app_name'.tr,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.history_rounded), onPressed: onHistory, tooltip: 'history'.tr),
          IconButton(icon: const Icon(Icons.menu_book_rounded), onPressed: onGuide, tooltip: 'guide'.tr),
          IconButton(icon: const Icon(Icons.settings), onPressed: onSettings, tooltip: 'settings'.tr),
        ],
      ),
    );
  }
}

// Type selector buttons — improved card style

class _TypeSelector extends StatelessWidget {
  final QrController ctrl;
  const _TypeSelector({required this.ctrl});

  static const _types = [
    (QrType.url, '🔗', 'qr_type_url'),
    (QrType.text, '📝', 'qr_type_text'),
    (QrType.wifi, '📶', 'qr_type_wifi'),
    (QrType.contact, '👤', 'qr_type_contact'),
    (QrType.email, '📧', 'qr_type_email'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      return SizedBox(
        height: 72.h,
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
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          colors: [
                            cs.primary.withValues(alpha: 0.18),
                            cs.primaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selected ? null : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: selected ? cs.primary : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(icon, style: TextStyle(fontSize: 20.sp)),
                    SizedBox(height: 3.h),
                    Text(
                      label.tr,
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

// QR Preview

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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: anim,
                  curve: Curves.easeOutBack,
                ),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: data.isEmpty
                  ? SizedBox(
                      key: const ValueKey('empty'),
                      width: 196.r,
                      height: 196.r,
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
                  : RepaintBoundary(
                      key: ctrl.qrKey,
                      child: Container(
                        key: ValueKey(data),
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
            ),
          ],
        ),
      );
    });
  }
}

// Color Picker

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

// Action Bar — gradient Generate/Share button

class _ActionBar extends StatelessWidget {
  final QrController ctrl;
  const _ActionBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final hasData = ctrl.qrData.value.isNotEmpty;
      return Column(
        children: [
          // Gradient CTA share button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: hasData
                  ? LinearGradient(
                      colors: [cs.primary, cs.tertiary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: hasData ? null : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: hasData
                  ? [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: hasData ? ctrl.shareQr : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.share_rounded,
                        size: 22.r,
                        color: hasData
                            ? cs.onPrimary
                            : cs.onSurface.withValues(alpha: 0.4),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'share'.tr,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: hasData
                              ? cs.onPrimary
                              : cs.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Secondary actions row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasData ? ctrl.copyContent : null,
                  icon: Icon(Icons.copy_rounded, size: 16.r),
                  label: Text(
                    'copy'.tr,
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              OutlinedButton(
                onPressed: ctrl.clearForm,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Icon(Icons.refresh_rounded, size: 18.r),
              ),
            ],
          ),
        ],
      );
    });
  }
}

// Form Widgets

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
          hint: 'url_hint'.tr,
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
          hint: 'wifi_ssid_hint'.tr,
          icon: Icons.wifi_rounded,
        ),
        SizedBox(height: 12.h),
        _Field(
          ctrl: ctrl.wifiPasswordCtrl,
          label: 'wifi_password'.tr,
          hint: 'wifi_password_hint'.tr,
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
          const securityOptions = ['WPA', 'WEP', 'nopass'];
          return Row(
            children: securityOptions.map((s) {
              final optionLabel = switch (s) {
                'WPA' => 'wifi_security_wpa',
                'WEP' => 'wifi_security_wep',
                _ => 'wifi_security_nopass',
              };
              final sel = ctrl.wifiSecurity.value == s;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ChoiceChip(
                  label: Text(optionLabel.tr),
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
          hint: 'contact_name_hint'.tr,
          icon: Icons.person_rounded,
        ),
        SizedBox(height: 12.h),
        _Field(
          ctrl: ctrl.contactPhoneCtrl,
          label: 'contact_phone'.tr,
          hint: 'contact_phone_hint'.tr,
          icon: Icons.phone_rounded,
          keyboard: TextInputType.phone,
        ),
        SizedBox(height: 12.h),
        _Field(
          ctrl: ctrl.contactEmailCtrl,
          label: 'contact_email'.tr,
          hint: 'contact_email_hint'.tr,
          icon: Icons.email_rounded,
          keyboard: TextInputType.emailAddress,
        ),
        SizedBox(height: 12.h),
        _Field(
          ctrl: ctrl.contactOrgCtrl,
          label: 'contact_org'.tr,
          hint: 'contact_org_hint'.tr,
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
          hint: 'email_address_hint'.tr,
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

// Reusable Field Widget

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

// Form Card

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

// History sheet

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
      'email': '📧',
    };
    return Text(
      icons[type] ?? '📝',
      style: const TextStyle(fontSize: 24),
    );
  }
}
