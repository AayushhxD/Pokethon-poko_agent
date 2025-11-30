import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/pokeagent.dart';

class PokeAgentCard extends StatelessWidget {
  final PokeAgent agent;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PokeAgentCard({
    super.key,
    required this.agent,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = AppTheme.getTypeColor(agent.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.glowingCardDecoration(typeColor),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [typeColor.withOpacity(0.3), AppTheme.cardColor],
                  ),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Expanded(
                    child: Center(
                      child: Hero(
                        tag: 'pokeagent-card-${agent.id}',
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: typeColor.withOpacity(0.2),
                            border: Border.all(color: typeColor, width: 3),
                          ),
                          child: ClipOval(
                            child:
                                agent.displayImageUrl.isNotEmpty
                                    ? Image.network(
                                      agent.displayImageUrl,
                                      key: ValueKey(agent.displayImageUrl),
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.catching_pokemon,
                                          size: 60,
                                          color: typeColor,
                                        );
                                      },
                                    )
                                    : Icon(
                                      Icons.catching_pokemon,
                                      size: 60,
                                      color: typeColor,
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Info Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          agent.name,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            agent.type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Level & Stage
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.yellow.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lv.${agent.level}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            Text(
                              'Stage ${agent.evolutionStage}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // XP Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'XP: ${agent.xp}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: agent.xpProgress,
                                minHeight: 6,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  typeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Delete Button
              if (onDelete != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.8),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                        size: 18,
                      ),
                    ),
                  ),
                ),

              // Evolution Badge
              if (agent.canEvolve)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
