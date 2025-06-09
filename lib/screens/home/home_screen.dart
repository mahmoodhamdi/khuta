import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khuta/core/theme/home_screen_theme.dart';
import 'package:khuta/models/child.dart';
import 'package:khuta/screens/child/add_child_screen.dart';
import 'package:khuta/screens/child/child_details_screen.dart';

import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Child> children = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final user = _auth.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .orderBy('createdAt', descending: false)
          .get();

      if (!mounted) return;

      setState(() {
        children = querySnapshot.docs
            .map((doc) => Child.fromFirestore(doc))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _addChild(Child child) async {
    if (!mounted) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('children')
          .add(child.toFirestore());

      if (mounted) {
        _fetchChildren(); // Refresh the list
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error_adding_child'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddChildScreen() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChildScreen(onAddChild: _addChild),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: HomeScreenTheme.backgroundColor(isDark),
        appBar: AppBar(
          title: Text('my_children'.tr()),
          backgroundColor: HomeScreenTheme.cardBackground(isDark),
          foregroundColor: HomeScreenTheme.primaryText(isDark),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: HomeScreenTheme.accentBlue(isDark),
                  ),
                )
              : error != null
              ? _buildErrorWidget(isDark)
              : children.isEmpty
              ? _buildEmptyState(isDark)
              : _buildChildrenList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddChildScreen,
          backgroundColor: HomeScreenTheme.accentBlue(isDark),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'error_loading_children'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: HomeScreenTheme.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error!,
            style: TextStyle(color: HomeScreenTheme.secondaryText(isDark)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchChildren,
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeScreenTheme.accentBlue(isDark),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: HomeScreenTheme.accentBlue(isDark).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.child_care,
              size: 80,
              color: HomeScreenTheme.accentBlue(isDark),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'no_children_yet'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HomeScreenTheme.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'add_child_description'.tr(),
              style: TextStyle(
                fontSize: 16,
                color: HomeScreenTheme.secondaryText(isDark),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddChildScreen,
            icon: const Icon(Icons.add),
            label: Text('add_first_child'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeScreenTheme.accentBlue(isDark),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return _buildChildCard(child);
      },
    );
  }

  Widget _buildChildCard(Child child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lastTest = child.testResults.isNotEmpty
        ? child.testResults.last
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: HomeScreenTheme.cardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeScreenTheme.cardShadow(isDark)],
      ),
      child: InkWell(
        onTap: () {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChildDetailsScreen(child: child),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar section
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          (child.gender == 'male'
                                  ? HomeScreenTheme.accentBlue(isDark)
                                  : HomeScreenTheme.accentPink(isDark))
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      child.gender == 'male' ? Icons.boy : Icons.girl,
                      size: 30,
                      color: child.gender == 'male'
                          ? HomeScreenTheme.accentBlue(isDark)
                          : HomeScreenTheme.accentPink(isDark),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HomeScreenTheme.primaryText(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.cake_outlined,
                              size: 14,
                              color: HomeScreenTheme.secondaryText(isDark),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${child.age} ${'years_old'.tr()}',
                              style: TextStyle(
                                fontSize: 14,
                                color: HomeScreenTheme.secondaryText(isDark),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (child.testResults.isNotEmpty) ...[
                const SizedBox(height: 16),
                // Test results section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black12 : Colors.grey[50])!,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'test_history'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: HomeScreenTheme.primaryText(isDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          if (lastTest != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,

                                  size: 24,
                                  color: HomeScreenTheme.secondaryText(isDark),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'last_test'.tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: HomeScreenTheme.secondaryText(
                                      isDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Text(
                              DateFormat.yMMMd().format(lastTest.date),
                              style: TextStyle(
                                fontSize: 14,
                                color: HomeScreenTheme.secondaryText(isDark),
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (lastTest != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: HomeScreenTheme.getScoreColor(
                                            lastTest.score,
                                            isDark,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Icon(
                                          lastTest.score >= 80
                                              ? Icons.trending_down
                                              : lastTest.score >= 60
                                              ? Icons.trending_up
                                              : Icons.emoji_events,
                                          size: 12,
                                          color: HomeScreenTheme.getScoreColor(
                                            lastTest.score,
                                            isDark,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'latest_score'.tr(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: HomeScreenTheme.secondaryText(
                                            isDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: HomeScreenTheme.getScoreColor(
                                  lastTest.score,
                                  isDark,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lastTest.score.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: HomeScreenTheme.getScoreColor(
                                    lastTest.score,
                                    isDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
