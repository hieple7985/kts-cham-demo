import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../domain/models/customer_model.dart';
import '../models/customer_list_options.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool selected;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final stageGroup = customer.listStageGroup;
    final stageColor = customer.listStageColor;
    final lastNote = customer.lastNoteSnippet;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s3),
      color: selected ? stageColor.withValues(alpha: 0.1) : AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? stageColor : AppColors.grey10,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: stageColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?',
                        style: AppTextStyle.headline.copyWith(
                          color: stageColor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),

                  // Name & Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer.fullName,
                                style: AppTextStyle.bodyStrong,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (customer.isDemo) ...[
                              const SizedBox(width: AppSpacing.s2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s2,
                                  vertical: AppSpacing.s1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.grey12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'DEMO',
                                  style: AppTextStyle.subtextStrong.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s1),
                        Text(
                          customer.phoneNumber,
                          style: AppTextStyle.caption,
                        ),
                      ],
                    ),
                  ),
                  if (selectionMode) ...[
                    const SizedBox(width: AppSpacing.s2),
                    Icon(
                      selected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: selected ? stageColor : AppColors.grey7,
                      size: 24,
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: AppSpacing.s3),

              // Stage & Notes
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s2,
                      vertical: AppSpacing.s1,
                    ),
                    decoration: BoxDecoration(
                      color: stageColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      stageGroup == CustomerListStageFilter.all
                          ? customer.stageName
                          : stageGroup.label,
                      style: AppTextStyle.subtextStrong.copyWith(
                        color: stageColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  if (customer.lastContactDate != null)
                    Expanded(
                      child: Text(
                        'Liên hệ: ${_formatLastContact(customer.lastContactDate!)}',
                        style: AppTextStyle.subtext.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else if (customer.tags.isNotEmpty)
                    Expanded(
                      child: Text(
                        customer.tags.join(', '),
                        style: AppTextStyle.subtext.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              if (lastNote != null && lastNote.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s2),
                Text(
                  lastNote,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastContact(DateTime dt) {
    final now = DateTime.now();
    final days = now.difference(dt).inDays;
    if (days <= 0) return 'hôm nay';
    if (days == 1) return 'hôm qua';
    if (days < 7) return '$days ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
