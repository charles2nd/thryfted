import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CustomButtonType {
  primary,
  secondary,
  outline,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CustomButtonType type;
  final IconData? icon;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = CustomButtonType.primary,
    this.icon,
    this.fullWidth = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonPadding = padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    
    Widget button;
    
    switch (type) {
      case CustomButtonType.primary:
        button = _buildPrimaryButton(buttonPadding);
        break;
      case CustomButtonType.secondary:
        button = _buildSecondaryButton(buttonPadding);
        break;
      case CustomButtonType.outline:
        button = _buildOutlineButton(buttonPadding);
        break;
      case CustomButtonType.text:
        button = _buildTextButton(buttonPadding);
        break;
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildPrimaryButton(EdgeInsetsGeometry padding) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
        elevation: 2,
        shadowColor: AppTheme.primaryColor.withOpacity(0.3),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(EdgeInsetsGeometry padding) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppTheme.accentColor.withOpacity(0.5),
        elevation: 2,
        shadowColor: AppTheme.accentColor.withOpacity(0.3),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlineButton(EdgeInsetsGeometry padding) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        disabledForegroundColor: AppTheme.primaryColor.withOpacity(0.5),
        side: BorderSide(
          color: isLoading 
              ? AppTheme.primaryColor.withOpacity(0.5) 
              : AppTheme.primaryColor,
          width: 1.5,
        ),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton(EdgeInsetsGeometry padding) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primaryColor,
        disabledForegroundColor: AppTheme.primaryColor.withOpacity(0.5),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == CustomButtonType.primary || type == CustomButtonType.secondary
                    ? Colors.white
                    : AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: AppTheme.button.copyWith(fontSize: 16),
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.button.copyWith(fontSize: 16),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppTheme.button.copyWith(fontSize: 16),
    );
  }
}