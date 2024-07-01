import 'package:bits_trade/data/modals/child_data_modal.dart';
import 'package:bits_trade/data/modals/parent_data_modal.dart';
import 'package:bits_trade/screens/dashboard/child_data_table.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/providers/dashboard_provider.dart';
import 'add_parent_form.dart';
import 'add_child_form.dart';
import 'parent_data_table.dart';
import '../../widgets/dotted_container.dart';


class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadParentData();
      ref.read(dashboardProvider.notifier).loadChildData();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // top bar color
      statusBarIconBrightness: Brightness.dark, // top bar icons
    ));

    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (dashboardState.parentData == null)
          ...List.generate(2, (index) => ParentDataShimmer())
            // ParentDataShimmer()
          else if (dashboardState.parentData?.data?.nameTag != null)
            ParentDataTable(parentData: dashboardState.parentData!.data!)
          else
            _buildAddParentContainer(context),
          const SizedBox(height: 50),
          if (dashboardState.parentData == null)
            ...List.generate(4, (_) => ChildDataShimmer())
          else if (dashboardState.parentData?.data?.nameTag != null)
            dashboardState.childData?.isNotEmpty == true
              ? ChildDataTable(childData: dashboardState.childData!)
              : _buildAddChildContainer(context)
          else
            Container()
        ],
      ),
    );
  }

  Widget _buildAddParentContainer(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: DottedBorderContainer(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 75),
            child: ElevatedButton(
              onPressed: () => _showAddParentModal(context),
              child: const Text(
                'Add Parent',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddChildContainer(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: DottedBorderContainer(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 75),
            child: ElevatedButton(
              onPressed: () => _showAddChildModal(context),
              child: const Text(
                'Add Child',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddParentModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      context: context,
      builder: (context) {
        return Container(
                 height: MediaQuery.of(context).size.height * 0.95,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: const AddParentForm(),
            ),
          ),
        );
      },
    );
  }

  void _showAddChildModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: const AddChildForm(),
            ),
          ),
        );
      },
    );
  }
}

class DashboardState extends StateNotifier<DashboardData> {
  final ParentApiService parentApiService;
  final ChildApiService childApiService;

  DashboardState(this.parentApiService, this.childApiService)
      : super(DashboardData());

  Future<void> loadParentData() async {
    final parentData = await parentApiService.getParents();
    state = state.copyWith(parentData: parentData);
  }

  Future<void> loadChildData() async {
    final childData = await childApiService.getChilds();
    state = state.copyWith(childData: childData);
  }
}

class DashboardData {
  final ParentData? parentData;
  final List<ChildData>? childData;

  DashboardData({this.parentData, this.childData});

  DashboardData copyWith({
    ParentData? parentData,
    List<ChildData>? childData,
  }) {
    return DashboardData(
      parentData: parentData ?? this.parentData,
      childData: childData ?? this.childData,
    );
  }
}

final dashboardProvider = StateNotifierProvider<DashboardState, DashboardData>(
  (ref) {
    final parentApiService = ref.watch(parentApiServiceProvider);
    final childApiService = ref.watch(childApiServiceProvider);
    return DashboardState(parentApiService, childApiService);
  },
);



class ParentDataShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.tertiary,
      highlightColor:Theme.of(context).colorScheme.secondary,
      child: Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(20),
        height: 100,
        child: Column(
          children: List.generate(
            2,
            (index) => Expanded(
              child: Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChildDataShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.tertiary,
      highlightColor: Theme.of(context).colorScheme.secondary,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        padding: const EdgeInsets.all(20),
        height: 80,
        child: Column(
          children: List.generate(
            1,
            (index) => Expanded(
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
