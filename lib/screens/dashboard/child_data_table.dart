import 'package:bits_trade/data/modals/get_funds_model.dart';
import 'package:bits_trade/data/modals/parent_positions_model.dart';
import 'package:bits_trade/screens/dashboard/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/modals/child_data_modal.dart';
import '../../data/providers/dashboard_provider.dart';
import 'add_child_form.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

class ChildDataTable extends ConsumerWidget {
  final List<ChildData> childData;

  const ChildDataTable({super.key, required this.childData});

  @override
  Widget build(BuildContext context, ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          // Add Child Button
          TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0))),
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: () {
              showModalBottomSheet(
                shape: const ContinuousRectangleBorder(
                    borderRadius: BorderRadius.zero),
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.95,
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: const SingleChildScrollView(
                      child: AddChildForm(
                        isEditing: false,
                      ),
                    ),
                  );
                },
              );
            },
            child: Row(
              children: [
                Text(
                  'Add Child',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(
                  width: 5,
                ),
                Image.asset(
                  'assets/edit_icon.png',
                  height: 20,
                  fit: BoxFit.cover,
                  width: 20,
                ),
              ],
            ),
          ),
          // DataTable for Children
          DataTable(
            headingRowColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.secondary),
            columns: const [
              DataColumn(label: Text('S.no')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text(' Login')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Multiplier')),
              // DataColumn(label: Text('Play/Pause')),
              DataColumn(label: Text(' Actions')), // Added Actions column
            ],
            rows: childData
                .map((child) => DataRow(
                      color: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.tertiary),
                      cells: _buildCells(context, child, ref),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  List<DataCell> _buildCells(BuildContext context, ChildData child, ref) {
    return [
      DataCell(Text(childData.indexOf(child).toString())),
      DataCell(Text(child.broker ?? ''), onTap: () {
        _navigateToDetailsScreen(context, child, ref);
      }),
      DataCell(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: child.loginStatus ?? false,
                onChanged: (bool value) {
                  value == true
                      ? null
                      : ref
                          .read(dashboardProvider.notifier)
                          .updateChildConnection(
                            child.id!,
                          ); // Update connection status
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.red,
                activeTrackColor: Theme.of(context).primaryColor,
                trackOutlineColor:
                    MaterialStateColor.resolveWith((states) => Colors.white),
                splashRadius: BorderSide.strokeAlignCenter,
              ),
            ),
            const Spacer()
          ],
        ),
        onTap: () {
          _navigateToDetailsScreen(context, child, ref); // Open DetailsScreen
        },
      ),
      DataCell(
          child.status == true
              ? Text(
                  'Active',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )
              : const Text(
                  'In Active',
                  style: TextStyle(color: Colors.red),
                ), onTap: () {
        _navigateToDetailsScreen(context, child, ref);
      }),
      DataCell(Text(child.multiplier ?? ''), onTap: () {
        _navigateToDetailsScreen(context, child, ref);
      }),

      DataCell(
        Row(
          children: [
            child.status == false
                ? IconButton(
                    onPressed: () async {
                      await ref
                          .read(dashboardProvider.notifier)
                          .updateChildStatus(child.id!, true);
                    },
                    icon: const Icon(
                      Icons.play_arrow_outlined,
                      color: Colors.teal,
                    ))
                : IconButton(
                    onPressed: () async {
                      await ref
                          .read(dashboardProvider.notifier)
                          .updateChildStatus(child.id!, false);
                    },
                    icon: const Icon(
                      Icons.pause_outlined,
                      color: Colors.teal,
                    )),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditChildBottomSheet(
                    context, child); // Show Edit Child form
              },
            ),
          ],
        ),
      ), // Actions column
    ];
  }

  void _navigateToDetailsScreen(
      BuildContext context, ChildData child, WidgetRef ref) async {
    ref.read(loadingProvider.notifier).state = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    GetFundsModel? fundsData =
        await ref.read(childApiServiceProvider).getFunds(child.id!);
    ParentPositionsModel? positionsData =
        await ref.read(childApiServiceProvider).getPositions(child.id!);
    Navigator.pop(context); // Remove loading dialog

    ref.read(loadingProvider.notifier).state = false;

    showModalBottomSheet(
      shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.zero),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DetailsScreen(
            fundsData,
            positionsData,
            childData: child,
          ),
        );
      },
    );
  }

  void _showEditChildBottomSheet(BuildContext context, ChildData child) {
    showModalBottomSheet(
      shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.zero),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: AddChildForm(
              child: child, // Pass the child data for editing
              isEditing: true,
            ),
          ),
        );
      },
    );
  }
}
