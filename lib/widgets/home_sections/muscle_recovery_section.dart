import 'package:flutter/material.dart';

import 'favorite_progress_section.dart';
import 'muscle_volume_section.dart';

class MuscleRecoverySection extends StatefulWidget {
  final void Function()? onScrollDownFromFavorites;
  const MuscleRecoverySection({super.key, this.onScrollDownFromFavorites});

  @override
  State<MuscleRecoverySection> createState() => _MuscleRecoverySectionState();
}

class _MuscleRecoverySectionState extends State<MuscleRecoverySection> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        const MuscleVolumeSection(),
        FavoriteProgressSection(onScrollDown: widget.onScrollDownFromFavorites),
      ],
    );
  }
}
