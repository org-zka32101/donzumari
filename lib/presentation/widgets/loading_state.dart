import 'package:flutter/material.dart';

/// Animated loading indicator with pulse effect
class PulseLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const PulseLoadingIndicator({
    Key? key,
    this.size = 50,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Loading overlay for full-screen loading state
class LoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String? message;
  final Duration? transitionDuration;

  const LoadingOverlay({
    Key? key,
    required this.isVisible,
    this.message,
    this.transitionDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: transitionDuration ?? const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: transitionDuration ?? const Duration(milliseconds: 300),
        color: Colors.black.withOpacity(isVisible ? 0.3 : 0),
        child: isVisible
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PulseLoadingIndicator(
                      color: Colors.white,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              )
            : null,
      ),
    );
  }
}

/// Skeleton loader for content preview
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Duration? animationDuration;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.animationDuration,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.6)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}

/// List of skeleton loaders
class SkeletonListLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const SkeletonListLoader({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(
              width: double.infinity,
              height: itemHeight,
            ),
            const SizedBox(height: 8),
            SkeletonLoader(
              width: 200,
              height: 12,
            ),
          ],
        );
      },
    );
  }
}

/// Empty state widget for no data scenarios
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Responsive loading state for async operations
class AsyncValueBuilder<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) onData;
  final Widget Function(BuildContext context, Object error, StackTrace? stack)? onError;
  final Widget Function(BuildContext context)? onLoading;

  const AsyncValueBuilder({
    Key? key,
    required this.value,
    required this.onData,
    this.onError,
    this.onLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) => onData(context, data),
      error: (error, stack) => onError != null
          ? onError!(context, error, stack)
          : _buildDefaultError(context, error),
      loading: () => onLoading != null
          ? onLoading!(context)
          : const Center(child: PulseLoadingIndicator()),
    );
  }

  Widget _buildDefaultError(BuildContext context, Object error) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'エラーが発生しました',
      message: error.toString(),
    );
  }
}

// Placeholder for AsyncValue type
class AsyncValue<T> {
  final T? _data;
  final Object? _error;
  final bool _isLoading;

  AsyncValue.data(this._data)
      : _error = null,
        _isLoading = false;

  AsyncValue.error(this._error)
      : _data = null,
        _isLoading = false;

  AsyncValue.loading()
      : _data = null,
        _error = null,
        _isLoading = true;

  R when<R>({
    required R Function(T) data,
    required R Function(Object, StackTrace?) error,
    required R Function() loading,
  }) {
    if (_isLoading) return loading();
    if (_error != null) return error(_error, null);
    if (_data != null) return data(_data as T);
    throw StateError('Invalid AsyncValue state');
  }
}
