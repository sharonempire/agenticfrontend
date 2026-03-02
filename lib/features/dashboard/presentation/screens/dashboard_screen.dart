import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const String routePath = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (dashboardProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        AppSnackbar.showError(context, dashboardProvider.errorMessage!);
        dashboardProvider.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: authProvider.isSubmitting
                ? null
                : () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 900
                ? 720.0
                : constraints.maxWidth;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: _DashboardBody(provider: dashboardProvider),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.provider});

  final DashboardProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined, size: 56),
              const SizedBox(height: 12),
              Text(
                'No dashboard data available.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => provider.fetchItems(forceRefresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchItems(forceRefresh: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: provider.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = provider.items[index];
          return Card(
            elevation: 1.5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (item.createdAt != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _formatDate(item.createdAt!),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day  $hour:$minute';
  }
}
