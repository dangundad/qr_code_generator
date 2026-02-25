import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GuidePage extends GetView<dynamic> {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('guide'.tr),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.16),
              cs.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'guide_title'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              _GuideCard(
                icon: Icons.smartphone,
                title: 'guide_tip_1_title'.tr,
                description: 'guide_tip_1_desc'.tr,
                color: cs.primary,
              ),
              SizedBox(height: 10.h),
              _GuideCard(
                icon: Icons.color_lens_outlined,
                title: 'guide_tip_2_title'.tr,
                description: 'guide_tip_2_desc'.tr,
                color: cs.secondary,
              ),
              SizedBox(height: 10.h),
              _GuideCard(
                icon: Icons.image,
                title: 'guide_tip_3_title'.tr,
                description: 'guide_tip_3_desc'.tr,
                color: cs.tertiary,
              ),
              SizedBox(height: 10.h),
              _GuideCard(
                icon: Icons.history,
                title: 'guide_tip_4_title'.tr,
                description: 'guide_tip_4_desc'.tr,
                color: cs.error,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.22)),
                ),
                child: Text(
                  'guide_footer'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: cs.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _GuideCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLowest.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
