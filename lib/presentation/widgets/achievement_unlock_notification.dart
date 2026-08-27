import 'package:flutter/material.dart';
import '../../data/models/achievement_model.dart';

/// Animated achievement unlock notification
class AchievementUnlockNotification extends StatefulWidget {
  final AchievementDefinition achievement;
  final int points;
  final VoidCallback? onDismissed;
  final Duration displayDuration;

  const AchievementUnlockNotification({
    Key? key,
    required this.achievement,
    required this.points,
    this.onDismissed,
    this.displayDuration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<AchievementUnlockNotification> createState() =>
      _AchievementUnlockNotificationState();

  /// Show achievement unlock notification
  static Future<void> show(
    BuildContext context,
    AchievementDefinition achievement,
    int points, {
    Duration displayDuration = const Duration(seconds: 5),
  }) async {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => AchievementUnlockNotification(
        achievement: achievement,
        points: points,
        displayDuration: displayDuration,
        onDismissed: () => overlayEntry?.remove(),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}

class _AchievementUnlockNotificationState
    extends State<AchievementUnlockNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Auto-dismiss after display duration
    Future.delayed(
      widget.displayDuration,
      () {
        if (mounted) {
          _animationController.reverse().then((_) {
            widget.onDismissed?.call();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () {
              _animationController.reverse().then((_) {
                widget.onDismissed?.call();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.shade600,
                    Colors.orange.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Trophy icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Achievement info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '実績解除！',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.achievement.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.achievement.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Points
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '+',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${widget.points}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
