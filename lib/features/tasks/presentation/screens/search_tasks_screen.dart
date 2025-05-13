import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmenot/core/constants/app_constants.dart';
import 'package:taskmenot/features/tasks/data/models/task_model.dart';
import '../widgets/task_item.dart';

class SearchTasksScreen extends StatefulWidget {
  const SearchTasksScreen({super.key});

  @override
  State<SearchTasksScreen> createState() => _SearchTasksScreenState();
}

class _SearchTasksScreenState extends State<SearchTasksScreen> {
  String _query = '';
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasksFromFirestore();
  }

  Future<void> _loadTasksFromFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final ownedTasksSnap = await FirebaseFirestore.instance
          .collection('tasks')
          .where('ownerId', isEqualTo: userId)
          .get();

      final sharedTasksSnap = await FirebaseFirestore.instance
          .collection('tasks')
          .where('sharedWith', arrayContains: userId)
          .get();

      final ownedTasks = ownedTasksSnap.docs.map((doc) {
        final data = doc.data();
        return Task.fromMap(data..['id'] = doc.id);
      }).toList();

      final sharedTasks = sharedTasksSnap.docs.map((doc) {
        final data = doc.data();
        return Task.fromMap(data..['id'] = doc.id);
      }).toList();

      final allTasks = [...ownedTasks, ...sharedTasks];

      setState(() {
        _allTasks = allTasks;
        _filteredTasks = allTasks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching tasks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _onSearch(String query) {
    setState(() {
      _query = query.toLowerCase();
      _filteredTasks = _allTasks.where((task) {
        return task.title.toLowerCase().contains(_query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Tasks', style: AppTextStyles.bodyLarge,)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search by title...',
                prefixIcon: const Icon(Icons.search),
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                filled: true,
                fillColor: AppColors.primaryLight.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredTasks.isEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, color: Colors.grey.shade400, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    'No matching tasks found',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filteredTasks.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return TaskItem(task: _filteredTasks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
