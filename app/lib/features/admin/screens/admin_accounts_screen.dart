import 'package:flutter/material.dart';
import '../../../core/constants/dimens.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/eco_card.dart';

class AdminAccountsScreen extends StatefulWidget {
  const AdminAccountsScreen({super.key});

  @override
  State<AdminAccountsScreen> createState() => _AdminAccountsScreenState();
}

class _AdminAccountsScreenState extends State<AdminAccountsScreen> {
  final UserRepository _userRepository = UserRepository();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!SupabaseService.instance.isInitialized) return;
    setState(() => _isLoading = true);
    try {
      final userList = await _userRepository.getAllUsers();
      if (mounted) {
        setState(() {
          _users = userList;
        });
      }
    } catch (e) {
      debugPrint('Error loading account management users: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh Accounts',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(EcoSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Account Records',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Reading directly from public.users and Supabase Auth metadata.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: EcoSpacing.m),
              Expanded(
                child: _users.isEmpty && !_isLoading
                    ? Center(
                        child: Text(
                          SupabaseService.instance.isInitialized
                              ? 'No user accounts found in public.users.'
                              : 'Live database connection uninitialized.',
                        ),
                      )
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) =>
                            _buildAccountCard(context, _users[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, Map<String, dynamic> user) {
    final String name = user['name']?.toString() ?? 'User';
    final String email = user['email']?.toString() ?? 'Managed by Supabase Auth';
    final String role = (user['user_type']?.toString() ?? 'Resident').toUpperCase();
    final String flatNo = user['flat_no']?.toString() ?? '';
    final int points = (user['eco_points'] as num? ?? 0).toInt();
    final int score = (user['eco_score'] as num? ?? 50).toInt();
    final String createdAt = user['created_at'] != null
        ? DateTime.tryParse(user['created_at'].toString())
                ?.toIso8601String()
                .substring(0, 10) ??
            'Unknown'
        : 'Unknown';

    Color roleColor = Colors.green;
    if (role == 'ADMIN') roleColor = Colors.purple;
    if (role == 'COLLECTOR') roleColor = Colors.orange;
    if (role == 'RECYCLER') roleColor = Colors.teal;

    return Padding(
      padding: const EdgeInsets.only(bottom: EcoSpacing.m),
      child: EcoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: roleColor.withValues(alpha: 0.15),
                  child: Icon(
                    role == 'ADMIN'
                        ? Icons.admin_panel_settings
                        : (role == 'COLLECTOR'
                            ? Icons.local_shipping
                            : (role == 'RECYCLER' ? Icons.recycling : Icons.person)),
                    color: roleColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: EcoSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        email.isNotEmpty ? email : 'Managed by Supabase Auth',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(EcoRadius.small),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: EcoSpacing.l),
            Wrap(
              spacing: EcoSpacing.l,
              runSpacing: EcoSpacing.s,
              children: [
                if (flatNo.isNotEmpty) _buildDetailChip('Unit: $flatNo'),
                _buildDetailChip('EcoPoints: $points'),
                _buildDetailChip('EcoScore: $score'),
                _buildDetailChip('Created: $createdAt'),
                _buildDetailChip('Password: Managed by Supabase Auth'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }
}
