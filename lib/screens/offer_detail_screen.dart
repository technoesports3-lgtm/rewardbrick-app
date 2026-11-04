import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme_design_system.dart';

class OfferDetailScreen extends StatelessWidget {
  final Map<dynamic, dynamic> offer;
  final VoidCallback onStartTask;

  const OfferDetailScreen({
    super.key,
    required this.offer,
    required this.onStartTask,
  });

  static const _background = bgLight;
  static const _deepBlue = textDark;
  static const _blue = primaryDarkBlue;
  static const _terracotta = accentCoral;

  String _value(String key, [String fallback = '']) =>
      (offer[key] ?? fallback).toString();

  @override
  Widget build(BuildContext context) {
    final title = _value('offer_title', 'Offer');
    final description = _value('offer_description');
    final imageUrl = _value('offer_image');
    final reward = _value('offer_virtual_currency');
    final type = _value('offer_type', 'Task').toUpperCase();
    final instructions = offer['offer_instructions'] is List
        ? (offer['offer_instructions'] as List)
            .map((instruction) => instruction.toString())
            .where((instruction) => instruction.trim().isNotEmpty)
            .toList()
        : description.trim().isEmpty
            ? <String>[]
            : <String>[description];

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        foregroundColor: _deepBlue,
        title: Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
                color: _deepBlue, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          _heroImage(imageUrl),
          const SizedBox(height: 14),
          _panel(
            title: 'Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: _terracotta, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F4),
                      borderRadius: BorderRadius.circular(13)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total reward',
                          style: GoogleFonts.poppins(
                              color: _terracotta, fontSize: 12)),
                      if (reward.isNotEmpty)
                        Row(children: [
                          const Icon(Icons.monetization_on_rounded,
                              color: Color(0xFFE0A91F), size: 21),
                          const SizedBox(width: 5),
                          Text(reward,
                              style: GoogleFonts.poppins(
                                  color: _terracotta,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17)),
                        ]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  _metaPill(Icons.bolt_rounded, type),
                  const SizedBox(width: 8),
                  if (_value('time_required').isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _metaPill(
                      Icons.timer_outlined,
                      '${_value('time_required')} min',
                    ),
                  ],
                ]),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _panel(
            title: 'Tasks',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (instructions.isEmpty)
                  Text('No additional instructions provided by the partner.',
                      style: GoogleFonts.poppins(
                          color: _terracotta, fontSize: 12, height: 1.3))
                else
                  ...instructions.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text('${entry.key + 1}. ${entry.value}',
                            style: GoogleFonts.poppins(
                                color: _terracotta, fontSize: 12, height: 1.3)),
                      )),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: _background,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onStartTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: _terracotta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Start Task',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _heroImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: url.isEmpty
          ? Container(
              height: 145,
              color: primaryLightBlue,
              child: const Icon(Icons.apps_rounded, color: _blue, size: 58),
            )
          : Image.network(url,
              height: 145,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  height: 145,
                  color: primaryLightBlue,
                  child:
                      const Icon(Icons.apps_rounded, color: _blue, size: 58))),
    );
  }

  Widget _panel({required String title, required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Colors.white, offset: Offset(-5, -5), blurRadius: 10),
            BoxShadow(
                color: primaryLightBlue, offset: Offset(5, 5), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    color: _terracotta,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );

  Widget _metaPill(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            color: const Color(0xFFE7F2F4),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: _deepBlue, size: 15),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  color: _deepBlue, fontSize: 10, fontWeight: FontWeight.w600)),
        ]),
      );
}
