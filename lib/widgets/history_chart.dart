import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class HistoryChart extends StatelessWidget {
  const HistoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    final values = [4.0, 3.0, 5.0, 2.0, 4.5];
    final labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blue),
        color: AppColors.card.withOpacity(0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(values.length, (i) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 18,
                      height: values[i] * 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [AppColors.blue, AppColors.purple],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[i],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Status Completo',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
