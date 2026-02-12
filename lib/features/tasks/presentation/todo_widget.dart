import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_button.dart';
import 'package:residence_lamandier_b/features/tasks/presentation/tasks_viewmodel.dart';

class TodoWidget extends ConsumerStatefulWidget {
  const TodoWidget({super.key});

  @override
  ConsumerState<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends ConsumerState<TodoWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksViewModelProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TO-DO LIST",
                style: AppTheme.luxuryTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.offWhite),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: AppTheme.offWhite),
                  decoration: InputDecoration(
                    hintText: "Nouvelle tâche...",
                    hintStyle: TextStyle(color: AppTheme.offWhite.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              LuxuryButton(
                label: "ADD",
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    ref.read(tasksViewModelProvider.notifier).addTask(_controller.text);
                    _controller.clear();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // List
          SizedBox(
            height: 300,
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text("Aucune tâche.", style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        activeColor: AppTheme.gold,
                        checkColor: AppTheme.darkNavy,
                        onChanged: (val) {
                          ref.read(tasksViewModelProvider.notifier).toggleTask(task.id, val ?? false);
                        },
                      ),
                      title: Text(
                        task.description,
                        style: TextStyle(
                          color: task.isCompleted ? Colors.grey : AppTheme.offWhite,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text("Error: $err", style: const TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
