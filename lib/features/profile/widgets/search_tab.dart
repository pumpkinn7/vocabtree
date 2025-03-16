import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import '../../../core/theme/text_styles.dart';
import '../models/friend_model.dart';
import '../services/friend_service.dart';

class SearchTab extends StatefulWidget {
  final String currentUserId;
  final FriendService friendService;

  const SearchTab({
    super.key, // แก้ไขเป็น super parameter
    required this.currentUserId,
    required this.friendService,
  });

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  List<FriendModel> searchResults = [];
  final _searchController = TextEditingController();

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final results = await widget.friendService.searchUsers(query);
    setState(() => searchResults = results);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BootstrapContainer(
      fluid: true,
      padding: const EdgeInsets.all(16.0),
      children: [
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-xs-12 col-sm-12 col-md-10 col-lg-8',
              offsets: "offset-xs-0 offset-sm-0 offset-md-1 offset-lg-2",
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'ค้นหาเพื่อน',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                style: AppTextStyles.inputText,
                onChanged: _searchUsers,
              ),
            ),
          ],
        ),
        const SizedBox(height: 90),
        BootstrapRow(
          children: [
            BootstrapCol(
              sizes: 'col-xs-12 col-sm-12 col-md-10 col-lg-8',
              offsets: "offset-xs-0 offset-sm-0 offset-md-1 offset-lg-2",
              child: searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? Center(
                      child: Text(
                        'ไม่พบผู้ใช้ที่คุณค้นหา',
                        style: AppTextStyles.body,
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: searchResults.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final user = searchResults[index];
                        final isCurrentUser =
                            user.userId == widget.currentUserId;

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                              image: user.profileImage.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(user.profileImage),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: user.profileImage.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            user.name,
                            style: AppTextStyles.subtitle,
                          ),
                          subtitle: Text(
                            user.email,
                            style: AppTextStyles.caption,
                          ),
                          trailing: isCurrentUser
                              ? Text(
                                  'คุณ',
                                  style: TextStyle(color: Colors.grey),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    await widget.friendService
                                        .sendFriendRequest(
                                      widget.currentUserId,
                                      user.userId,
                                    );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('ส่งคำขอแล้ว')),
                                    );
                                  },
                                  child: const Text('ส่งคำขอ'),
                                ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
