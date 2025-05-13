// lib/features/home/presentation/screens/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
// import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:taskmenot/core/constants/app_constants.dart';
import 'package:taskmenot/features/auth/app_auth_provider.dart';
import 'package:taskmenot/features/tasks/data/models/task_model.dart';
import 'package:taskmenot/features/tasks/task_provider.dart';

import '../../../tasks/presentation/screens/search_tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String _filter = 'All'; // Default filter
  String _sortBy = 'Title'; // Default sort

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<AppAuthProvider>(context, listen: false).currentUser?.uid;
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Provider.of<TaskProvider>(context, listen: false).fetchAllTasks();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppAuthProvider>(context).currentUser;
    final taskProvider = Provider.of<TaskProvider>(context);
    final todaysTasks = taskProvider.todaysTasks;
    final upcomingTasks = taskProvider.upcomingTasks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, user),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = Provider.of<AppAuthProvider>(context, listen: false).currentUser?.uid;
          if (userId != null) {
            await taskProvider.fetchAllTasks();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingHeader(user),
              const SizedBox(height: 16),
              _buildSummaryCards(taskProvider),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildSectionHeader('Today\'s Priority Tasks',
                  onViewAll: () => _navigateToAllTasks(context)),
              _buildTaskList(todaysTasks, taskProvider),
              const SizedBox(height: 16),
              _buildSectionHeader('Upcoming Tasks'),
              _buildUpcomingTasks(upcomingTasks, taskProvider),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _navigateToAddTask(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, firebase_auth.User? user) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: const Text('taskmenot', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  )))
                ],
              ),
          onPressed: () => _navigateToNotifications(context),
        ),
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: const ListTile(
                leading: Icon(Icons.person),
                title: Text('My Profile'),
              ),
              onTap: () => Future(() => _navigateToProfile(context)),
            ),
            PopupMenuItem(
              value: 'settings',
              child: const ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
              onTap: () => Future(() => _navigateToSettings(context)),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red,),
                title: Text('Logout', style: TextStyle(color: Colors.red),),
              ),
            ),
          ],
          onSelected: (value) async {
            if (value == 'logout') {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await Provider.of<AppAuthProvider>(context, listen: false).signOut();
              }
            }
            // Handle other menu items
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName!.substring(0, 1).toUpperCase()
                    : user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingHeader(firebase_auth.User? user) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String displayName = user.email ?? 'User';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          displayName = data['name'] ?? user.email ?? 'User';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting,',
                    style: const TextStyle(
                      fontSize: 24,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              // Logo Image
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Image.asset(
                  'assets/images/Logo.png',
                  width: 60,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildSummaryCards(TaskProvider taskProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.access_time,
              value: taskProvider.upcomingTaskCount.toString(),
              label: 'Upcoming',
              color: AppColors.primary,
              backgroundColor: AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.check_circle,
              value: '${taskProvider.completedTaskCount}/${taskProvider.totalTaskCount}',
              label: 'Completed',
              color: Colors.green,
              backgroundColor: Colors.green.withOpacity(0.15),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              icon: Icons.people,
              value: taskProvider.sharedTaskCount.toString(),
              label: 'Shared',
              color: Colors.blue,
              backgroundColor: Colors.blue.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.filter_alt, size: 20, color: AppColors.primary),
              label: const Text(
                'Filter',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => _buildFilterSortSheet(() {
                    setState(() {}); // Reference to the parent setState
                  }),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.search, size: 20, color: AppColors.primary),
              label: const Text(
                'Search Tasks',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchTasksScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterSortSheet(VoidCallback onApply) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter & Sort Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 16),
              // Filter Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['All', 'Completed', 'Incomplete'].map((filter) {
                  return ChoiceChip(
                    label: Text(filter),
                    selected: _filter == filter,
                    onSelected: (_) {
                      setModalState(() => _filter = filter);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              // Sort Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Title', 'Due Soon', 'Due Latest'].map((sortOption) {
                  return ChoiceChip(
                    label: Text(sortOption),
                    selected: _sortBy == sortOption,
                    onSelected: (_) {
                      setModalState(() => _sortBy = sortOption);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close sheet
                  onApply(); // <-- Triggers a rebuild of HomeScreen
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                'View All',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, TaskProvider taskProvider) {
    List<Task> filteredTasks = tasks;

    // Apply Filter
    if (_filter == 'Completed') {
      filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
    } else if (_filter == 'Incomplete') {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    }

    // Apply Sort
    if (_sortBy == 'Title') {
      filteredTasks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (_sortBy == 'Due Soon') {
      filteredTasks.sort((a, b) => a.dueDate?.compareTo(b.dueDate ?? DateTime.now()) ?? 0);
    } else if (_sortBy == 'Due Latest') {
      filteredTasks.sort((a, b) => b.dueDate?.compareTo(a.dueDate ?? DateTime.now()) ?? 0);
    }

    if (filteredTasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, color: Colors.grey, size: 48),
              SizedBox(height: 8),
              Text('No tasks match your filter.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: filteredTasks.map((task) => _buildTaskItem(task, taskProvider)).toList(),
      ),
    );
  }


  Widget _buildTaskItem(Task task, TaskProvider taskProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => taskProvider.deleteTask(task.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/task-detail',
              arguments: task
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  if (value != null) {
                    taskProvider.toggleTaskCompletion(task);
                  }
                },
                checkColor: AppColors.primary,
                fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                  return Colors.white;
                }),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  color: Colors.white.withOpacity(task.isCompleted ? 0.5 : 1.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        task.description!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (task.dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('h:mm a').format(task.dueDate!),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              trailing: _buildPriorityChip(task.priority),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color chipColor;
    switch (priority.toLowerCase()) {
      case 'high':
        chipColor = Colors.red;
        break;
      case 'medium':
        chipColor = Colors.orange;
        break;
      case 'low':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        priority,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildUpcomingTasks(List<Task> tasks, TaskProvider taskProvider) {
    if (tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, color: Colors.grey, size: 48),
              SizedBox(height: 8),
              Text(
                'No upcoming tasks. Enjoy your free time!',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: tasks
            .take(3)
            .map((task) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/task-detail',
                arguments: task,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          if (task.dueDate != null)
                            const SizedBox(height: 4),
                          if (task.dueDate != null)
                            Text(
                              DateFormat('EEE, MMM d • h:mm a').format(task.dueDate!),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        if (value != null) {
                          taskProvider.toggleTaskCompletion(task);
                        }
                      },
                      checkColor: AppColors.primary,
                      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                        return Colors.white;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }


  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _navigateToAddTask(BuildContext context) {
    Navigator.pushNamed(context, '/add-task');
  }

  void _navigateToAllTasks(BuildContext context) {
    Navigator.pushNamed(context, '/tasks');
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.pushNamed(context, '/notifications');
  }

}