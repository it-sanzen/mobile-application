import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/models/document.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  int _selectedCategory = 0;
  bool _isLoading = true;
  List<DocumentModel> _documents = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    setState(() => _isLoading = true);
    try {
      final token = await TokenService.getToken();
      final response = await ApiService.get('/documents/my', token: token);
      if (response['success']) {
        final List<dynamic> data = response['data'];
        setState(() {
          _documents = data.map((json) => DocumentModel.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? 'Failed to load documents')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  List<String> _categories(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [l10n.all, l10n.contracts, l10n.receipts, l10n.noc, 'Others'];
  }

  List<DocumentModel> _filteredDocuments(BuildContext context) {
    List<DocumentModel> filtered = _documents;
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) => 
        d.title.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Filter by category
    if (_selectedCategory == 0) return filtered;
    
    final cats = ['All', 'Contract', 'Receipt', 'NOC', 'Other'];
    final selectedCategory = cats[_selectedCategory];
    return filtered.where((d) => d.type == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildCategoryChips(context),
          Expanded(
            child: _buildDocumentList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          if (!_isSearching)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.yourFiles,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGrey.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.myDocuments,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          if (_isSearching)
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: 'Search documents...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: AppColors.primaryGreen, size: 20),
                    hintStyle: TextStyle(color: AppColors.darkGrey.withValues(alpha: 0.5)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
          if (!_isSearching) const Spacer(),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isSearching ? AppColors.primaryGreen.withValues(alpha: 0.1) : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isSearching ? [] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: AppColors.primaryGreen,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final cats = _categories(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(cats.length, (index) {
            final isSelected = _selectedCategory == index;
            return Padding(
              padding: EdgeInsets.only(right: index < cats.length - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen : AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.lightGrey,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Text(
                    cats[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.darkGrey,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDocumentList(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }
    final docs = _filteredDocuments(context);
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: AppColors.darkGrey.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              'No documents found',
              style: TextStyle(color: AppColors.darkGrey.withValues(alpha: 0.5)),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: docs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildDocumentCard(docs[index]),
    );
  }

  Widget _buildDocumentCard(DocumentModel doc) {
    String dateStr = '${doc.createdAt.day}/${doc.createdAt.month}/${doc.createdAt.year}';
    
    IconData icon = Icons.description;
    Color iconColor = AppColors.primaryGreen;
    Color iconBgColor = const Color(0xFFE8F5E9);

    if (doc.type == 'Receipt') {
      icon = Icons.receipt_long;
      iconColor = const Color(0xFFE65100);
      iconBgColor = const Color(0xFFFFF3E0);
    } else if (doc.type == 'NOC') {
      icon = Icons.verified_outlined;
      iconColor = const Color(0xFF1565C0);
      iconBgColor = const Color(0xFFE3F2FD);
    } else if (doc.type == 'Title Deed') {
      icon = Icons.landscape_outlined;
      iconColor = const Color(0xFF2E7D32);
      iconBgColor = const Color(0xFFE8F5E9);
    } else if (doc.type == 'Identification') {
      icon = Icons.badge_outlined;
      iconColor = const Color(0xFFC62828);
      iconBgColor = const Color(0xFFFFEBEE);
    } else if (doc.type == 'Other') {
      icon = Icons.more_horiz;
      iconColor = const Color(0xFF455A64);
      iconBgColor = const Color(0xFFECEFF1);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Document icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          // Document info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        doc.type,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkGrey.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Download / view button
          GestureDetector(
            onTap: () async {
              try {
                // First check if the file is available
                final downloadUrl = '${ApiService.baseUrl}/documents/${doc.id}/download';
                final checkResponse = await http.head(Uri.parse(downloadUrl));
                
                if (checkResponse.statusCode == 200) {
                  // File exists, proceed with download
                  final url = Uri.parse(downloadUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File not available for download'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not download document. File may not exist.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.file_download_outlined,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
