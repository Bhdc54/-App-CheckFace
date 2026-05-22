import 'package:flutter/material.dart';
import '../main.dart';

/// Toggle switch com ícones Material monocromáticos (sem cor fixa).
class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_rebuild);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final iconColor = Theme.of(context).iconTheme.color;
    final trackColor = Theme.of(context).colorScheme.surfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GestureDetector(
        onTap: () => themeNotifier.toggle(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 64,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: trackColor,
            border: Border.all(
              color: iconColor?.withOpacity(0.3) ?? Colors.grey,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Ícone lua (esquerda)
              Positioned(
                left: 6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    Icons.dark_mode,
                    size: 14,
                    color: iconColor?.withOpacity(0.6),
                  ),
                ),
              ),
              // Ícone sol (direita)
              Positioned(
                right: 6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    Icons.light_mode,
                    size: 14,
                    color: iconColor?.withOpacity(0.6),
                  ),
                ),
              ),
              // Bolinha deslizante com ícone ativo
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: isDark ? 2 : 34,
                top: 2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      size: 14,
                      color: Colors.white,
                    ),
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