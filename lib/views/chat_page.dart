import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthapp/view_models/controller/chat_page_controller.dart';
import 'package:healthapp/view_models/services/bottom_nav_services.dart';
import 'package:healthapp/view_models/services/chat_socket.dart';
import 'package:healthapp/views/messages_page.dart';
import 'package:healthapp/views/widgets/bottomnavbar.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ChatPageScreen extends StatefulWidget {
  const ChatPageScreen({super.key});

  @override
  State<ChatPageScreen> createState() => _ChatPageScreenState();
}

class _ChatPageScreenState extends State<ChatPageScreen>
    with TickerProviderStateMixin {
  final ChatService chatService = Get.find<ChatService>();
  final ChatPageController chatPageController = Get.put(ChatPageController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // chatService.onInit();
    chatPageController.onInit();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.chat_bubble, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Chats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'AI-powered health assistant',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_ios, color: Colors.grey[700]),
        //   onPressed: () => Get.back(),
        // ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.search, color: Colors.grey[700]),
        //     onPressed: () {
        //       _showSearchDialog();
        //     },
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.more_vert, color: Colors.grey[700]),
        //     onPressed: () {
        //       _showOptionsMenu();
        //     },
        //   ),
        // ],
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Info Card
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.green.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.psychology, color: Colors.blue, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Health Assistant',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Chat about your medical documents and get personalized insights',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chat List
            Expanded(
              child: PagingListener(
                controller: chatPageController.chatPaginationController,
                builder: (context, state, fetchNextPage) {
                  return PagedListView<int, Map<String, dynamic>>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, item, index) {
                        return _buildChatCard(item, index);
                      },
                      firstPageErrorIndicatorBuilder: (context) =>
                          _buildErrorWidget(),
                      newPageErrorIndicatorBuilder: (context) =>
                          _buildErrorWidget(),
                      firstPageProgressIndicatorBuilder: (context) =>
                          _buildLoadingWidget(),
                      newPageProgressIndicatorBuilder: (context) =>
                          _buildLoadingWidget(),
                      noItemsFoundIndicatorBuilder: (context) =>
                          _buildEmptyWidget(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Bottomnavbar(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showNewChatDialog();
        },
        backgroundColor: Colors.green,
        icon: Icon(Icons.add_comment, color: Colors.white),
        label: Text('New Chat', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> item, int index) {
    final aiContext =
        item['medical_document_ai_context'] ?? 'General Health Chat';
    final chatId = item['_id'] ?? 'N/A';
    final lastMessage = _getLastMessage(item);
    final timeAgo = _getTimeAgo(item);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(
              () => MessagesPageScreen(),
              arguments: {"room_id": chatId},
              transition: Transition.rightToLeft,
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Chat Avatar
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getChatGradient(index),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getChatIcon(aiContext),
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                SizedBox(width: 16),

                // Chat Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chat Title
                      Text(
                        _getChatTitle(aiContext),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),

                      // Last Message Preview
                      Text(
                        lastMessage,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),

                      // Time and Status
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Loading your chats...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  chatPageController.chatPaginationController.refresh(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No chats yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start a conversation with your AI health assistant',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showNewChatDialog(),
              icon: Icon(Icons.add_comment),
              label: Text('Start New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getChatGradient(int index) {
    final gradients = [
      [Colors.blue.shade400, Colors.blue.shade600],
      [Colors.green.shade400, Colors.green.shade600],
      [Colors.purple.shade400, Colors.purple.shade600],
      [Colors.orange.shade400, Colors.orange.shade600],
      [Colors.teal.shade400, Colors.teal.shade600],
    ];
    return gradients[index % gradients.length];
  }

  IconData _getChatIcon(String context) {
    if (context.toLowerCase().contains('heart')) return Icons.favorite;
    if (context.toLowerCase().contains('brain')) return Icons.psychology;
    if (context.toLowerCase().contains('lab')) return Icons.science;
    if (context.toLowerCase().contains('prescription')) return Icons.medication;
    return Icons.health_and_safety;
  }

  String _getChatTitle(String aiContext) {
    if (aiContext.length > 50) {
      return aiContext.substring(0, 50) + '...';
    }
    return aiContext.isEmpty ? 'Health Consultation' : aiContext;
  }

  String _getLastMessage(Map<String, dynamic> item) {
    // This would typically come from the last message in the chat
    return 'Tap to continue your health consultation...';
  }

  String _getTimeAgo(Map<String, dynamic> item) {
    // This would typically be calculated from the actual timestamp
    return 'Recent';
  }

  void _showSearchDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.search, color: Colors.green),
            SizedBox(width: 8),
            Text('Search Chats'),
          ],
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Search your medical chats...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement search functionality
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.archive, color: Colors.orange),
              title: Text('Archived Chats'),
              onTap: () {
                Get.back();
                // TODO: Show archived chats
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey),
              title: Text('Chat Settings'),
              onTap: () {
                Get.back();
                // TODO: Show chat settings
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.blue),
              title: Text('Help & Support'),
              onTap: () {
                Get.back();
                // TODO: Show help
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewChatDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_comment, color: Colors.green),
            SizedBox(width: 8),
            Text('Start New Chat'),
          ],
        ),
        content: Text(
          'Would you like to start a new health consultation with your AI assistant?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Start new chat functionality
              Get.to(() => MessagesPageScreen());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Start Chat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
