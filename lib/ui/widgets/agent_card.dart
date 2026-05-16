import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AgentCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badge;
  final bool isActive;
  final String? imagePath;

  const AgentCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
    this.isActive = false,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      onTapHint: 'Open $title',
      label: '$title agent card',
      hint: isActive ? '$title is active' : 'Tap to open $title',
      value: badge ?? (isActive ? 'Active' : 'Inactive'),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? color : Colors.white24,
              width: isActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: isActive ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (imagePath != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imagePath != null)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          imagePath!,
                          width: 32,
                          height: 32,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            icon,
                            size: 32,
                            color: isActive ? color : Colors.white70,
                          ),
                        ),
                      )
                    else
                      Icon(
                        icon,
                        size: 32,
                        color: isActive ? color : Colors.white70,
                      ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive ? 'Active' : 'Tap to open',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ).animate().scale(),
      ),
    );
  }
}
