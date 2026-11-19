import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes.dart';

/// Item Tile Pengumuman Kampus yang dioptimasi dengan [const] constructor
/// dan tidak memicu build method induk saat disentuh (ink-ripple terisolasi).
class AnnouncementCardTile extends StatelessWidget {
  const AnnouncementCardTile({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    this.isHighlight = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isHighlight ? const Color(0xFFEFF6FF) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isHighlight
                ? const Color(0xFF93C5FD)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isHighlight
                ? const Color(0xFF1E3A8A)
                : Colors.grey.shade200,
            child: Text(
              id,
              style: TextStyle(
                color: isHighlight ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () => context.go(AppRoutes.announcementDetail(id)),
        ),
      ),
    );
  }
}
