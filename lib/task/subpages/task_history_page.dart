import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:treemate/task/models/task_history_model.dart';
import 'package:treemate/task/widgets/task_history_card_widget.dart';

class TaskHistoryScreen extends StatelessWidget {
  const TaskHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskHistoryModel(),
      child: Consumer<TaskHistoryModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Task History',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              centerTitle: true,
            ),
            body: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      FilterButton(),
                      SizedBox(width: 10),
                      FilterDropdown(),
                    ],
                  ),
                ),
                Expanded(
                  child: TaskHistoryList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFCDE1D2),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Symbols.tune, color: Colors.black),
        onPressed: () {
          // Implement filter functionality
        },
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  const FilterDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskHistoryModel>(
      builder: (context, model, child) {
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFCDE1D2),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: model.selectedFilter,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  model.setFilter(newValue);
                }
              },
              items: <String>['All', 'Completed', 'Pending']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              elevation: 2,
              style: const TextStyle(color: Colors.black),
              dropdownColor: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class TaskHistoryList extends StatefulWidget {
  const TaskHistoryList({super.key});

  @override
  _TaskHistoryListState createState() => _TaskHistoryListState();
}

class _TaskHistoryListState extends State<TaskHistoryList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_onScroll); // Commented out pagination listener
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // void _onScroll() {
  //   if (_scrollController.position.pixels ==
  //       _scrollController.position.maxScrollExtent) {
  //     Provider.of<TaskHistoryModel>(context, listen: false).fetchTasks();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskHistoryModel>(
      builder: (context, model, child) {
        if (model.isLoading && model.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (model.errorMessage != null) {
          return Center(
              child: Text('Error fetching tasks: ${model.errorMessage}'));
        }

        if (model.tasks.isEmpty) {
          return const NoTaskHistory();
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: model.tasks.length + (model.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == model.tasks.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return TaskCard(task: model.tasks[index]);
          },
        );
      },
    );
  }
}

class NoTaskHistory extends StatelessWidget {
  const NoTaskHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "You don't have any tasks history",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
