import 'package:flutter/material.dart';
import '../../../../core/data/api/api_service.dart';
import 'package:frontend/core/widgets/styled_drawer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:frontend/core/design/app_design_system.dart';

class HintsSheet extends StatefulWidget {
  final String sceneDescription;
  final List<Map<String, String>> history;
  final Function(String) onHintSelected;
  final List<String>? cachedHints; // Optional pre-loaded hints
  final Function(List<String>)? onHintsCached; // Callback to save hints

  const HintsSheet({
    super.key,
    required this.sceneDescription,
    required this.history,
    required this.onHintSelected,
    this.cachedHints,
    this.onHintsCached,
  });

  @override
  State<HintsSheet> createState() => _HintsSheetState();
}

class _HintsSheetState extends State<HintsSheet> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<String> _hints = [];
  String? _error;

  @override
  void initState() {
    super.initState();

    // Use cached hints if available
    if (widget.cachedHints != null && widget.cachedHints!.isNotEmpty) {
      _hints = widget.cachedHints!;
      _isLoading = false;
    } else {
      _loadHints();
    }
  }

  Future<void> _loadHints() async {
    try {
      final response = await _apiService.getHints(
        widget.sceneDescription,
        widget.history,
      );
      if (mounted) {
        setState(() {
          _hints = response.hints;
          _isLoading = false;
        });

        // Save hints to cache via callback
        if (widget.onHintsCached != null) {
          widget.onHintsCached!(_hints);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      child: StyledDrawer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (fixed at top)
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Suggestions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Scrollable content
            Flexible(child: SingleChildScrollView(child: _buildContent())),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: AppColors.lightDivider,
        highlightColor: AppColors.lightSurface,
        child: Column(
          children: List.generate(3, (index) => _buildSkeletonItem()),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Failed to load suggestions: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadHints();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _hints
          .map(
            (hint) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.onHintSelected(hint);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightDivider),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            hint,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightTextPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                        // Arrow removed as requested ("remove card right side operation")
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text Block 1
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          // Text Block 2 (shorter)
          Container(
            width: 150,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
