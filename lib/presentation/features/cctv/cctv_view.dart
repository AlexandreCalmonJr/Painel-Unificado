import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CCTVView extends StatelessWidget {
  const CCTVView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 16 / 11,
      children: [
        _buildCameraFeed('Entrada Principal', 'Sem sinal', true, false),
        _buildCameraFeed('Sala Técnica', 'Rack Servidores', false, true),
      ],
    );
  }

  Widget _buildCameraFeed(
    String title,
    String subtitle,
    bool isLive,
    bool isRecording,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: const Color(0xFF1E293B)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Video Feed
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLive ? LucideIcons.camera : LucideIcons.server,
                          size: 48,
                          color: const Color(0xFF334155).withOpacity(0.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Live/Rec Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isRecording
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isRecording ? 'REC' : 'LIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Controls
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF334155)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isRecording ? 'Playback' : 'PTZ Controls',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
