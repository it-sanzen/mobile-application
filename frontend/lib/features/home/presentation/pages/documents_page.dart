import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/token_service.dart';
import '../../../../core/models/document.dart';
import 'package:google_fonts/google_fonts.dart';
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isSearching)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.yourFiles.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.primaryGreen.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.myDocuments,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          if (_isSearching)
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search documents...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: AppColors.primaryGreen, size: 20),
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.darkGrey.withValues(alpha: 0.4),
                      fontSize: 15,
                    ),
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
          const SizedBox(width: 16),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isSearching ? AppColors.white : AppColors.primaryGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                boxShadow: _isSearching ? [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [],
              ),
              child: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: AppColors.primaryDark,
                size: 20,
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
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(cats.length, (index) {
            final isSelected = _selectedCategory == index;
            return Padding(
              padding: EdgeInsets.only(right: index < cats.length - 1 ? 12 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryDark : const Color(0xFFF3F4F3),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryDark.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    cats[index],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: isSelected ? AppColors.white : AppColors.primaryDark.withValues(alpha: 0.6),
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
    Color iconBgColor = const Color(0xFFF3F4F3);

    if (doc.type == 'Receipt') {
      icon = Icons.receipt_long;
    } else if (doc.type == 'NOC') {
      icon = Icons.verified_outlined;
    } else if (doc.type == 'Title Deed') {
      icon = Icons.landscape_outlined;
    } else if (doc.type == 'Identification') {
      icon = Icons.badge_outlined;
    } else if (doc.type == 'Other') {
      icon = Icons.more_horiz;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1C).withValues(alpha: 0.04), // Ambient shadow defined in design system
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Luxury Document icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 24),
          ),
          const SizedBox(width: 16),
          // Document info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      doc.type.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark.withValues(alpha: 0.6),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDark.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Elegant Download Button
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
              margin: const EdgeInsets.only(left: 8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_downward_rounded,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
