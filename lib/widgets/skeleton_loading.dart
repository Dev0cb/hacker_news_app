import 'package:flutter/material.dart';

class SkeletonLoading extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonLoading({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = 4,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2A2A2A),
                const Color(0xFF3A3A3A),
                const Color(0xFF2A2A2A),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ArticleSkeleton extends StatelessWidget {
  const ArticleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            const SkeletonLoading(height: 20, width: double.infinity),
            const SizedBox(height: 8),
            const SkeletonLoading(height: 16, width: 200),
            const SizedBox(height: 8),
            // Métadonnées
            Row(
              children: [
                const SkeletonLoading(height: 12, width: 80),
                const SizedBox(width: 16),
                const SkeletonLoading(height: 12, width: 60),
                const SizedBox(width: 16),
                const SkeletonLoading(height: 12, width: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CommentSkeleton extends StatelessWidget {
  final int depth;

  const CommentSkeleton({super.key, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auteur et temps
              Row(
                children: [
                  const SkeletonLoading(height: 12, width: 100),
                  const SizedBox(width: 8),
                  const SkeletonLoading(height: 12, width: 80),
                ],
              ),
              const SizedBox(height: 8),
              // Contenu
              const SkeletonLoading(height: 16, width: double.infinity),
              const SizedBox(height: 4),
              const SkeletonLoading(height: 16, width: 250),
            ],
          ),
        ),
      ),
    );
  }
}
