import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AvatarView extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final IconData? placeholderIcon;
  final Color? backgroundColor;

  const AvatarView({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.placeholderIcon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.1),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final initial = name?.isNotEmpty == true ? name![0].toUpperCase() : '?';
    return Container(
      color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: placeholderIcon != null
            ? Icon(
                placeholderIcon,
                size: size * 0.5,
                color: AppColors.primary,
              )
            : Text(
                initial,
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
      ),
    );
  }
}