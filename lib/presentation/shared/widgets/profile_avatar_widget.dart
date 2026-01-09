// File: lib/widgets/profile_avatar_widget.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';

/// Widget de avatar do usuário com iniciais
class ProfileAvatarWidget extends StatelessWidget {

  const ProfileAvatarWidget({
    super.key,
    required this.username,
    this.size = 40,
    this.isOnline = false,
    this.imageUrl,
    this.onTap,
  });
  final String username;
  final double size;
  final bool isOnline;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Avatar principal
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _getGradientForUsername(username),
              border: Border.all(
                color: AppColors.border.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child:
                imageUrl != null
                    ? ClipOval(
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildInitials();
                        },
                      ),
                    )
                    : _buildInitials(),
          ),

          // Indicador de status online
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials(username);

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1))
        .toUpperCase();
  }

  LinearGradient _getGradientForUsername(String name) {
    // Gera um gradiente baseado no hash do nome
    final hash = name.hashCode.abs();
    final hue = (hash % 360).toDouble();

    final color1 = HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
    final color2 = HSLColor.fromAHSL(1.0, (hue + 30) % 360, 0.6, 0.4).toColor();

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color1, color2],
    );
  }
}

/// Widget de avatar compacto para usar em listas
class CompactAvatarWidget extends StatelessWidget {

  const CompactAvatarWidget({
    super.key,
    required this.username,
    this.isOnline = false,
    this.imageUrl,
  });
  final String username;
  final bool isOnline;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarWidget(
      username: username,
      size: 32,
      isOnline: isOnline,
      imageUrl: imageUrl,
    );
  }
}
