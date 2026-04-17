import 'package:flutter/material.dart';

/// A simple loading indicator widget
/// 
/// Displays a centered CircularProgressIndicator with optional message.
class LoadingWidget extends StatelessWidget {
  /// Optional message to display below the loading indicator
  final String? message;
  
  /// Color of the loading indicator
  final Color? color;
  
  /// Size of the loading indicator
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color ?? Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
