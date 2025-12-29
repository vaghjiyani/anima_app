import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import '../services/jikan_api_service.dart';

class MagazinesPage extends StatefulWidget {
  const MagazinesPage({super.key});

  @override
  State<MagazinesPage> createState() => _MagazinesPageState();
}

class _MagazinesPageState extends State<MagazinesPage> {
  List<Map<String, dynamic>> _magazines = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMagazines();
  }

  Future<void> _loadMagazines() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final magazines = await JikanApiService.getMagazines();

      if (mounted) {
        setState(() {
          _magazines = magazines;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load magazines';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Magazines',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: Container(
        decoration: AppColors.themedPrimaryGradient(context),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadMagazines,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.only(
                  top: ResponsiveHelper.isDesktop(context) ? 100 : 80,
                  left: ResponsiveHelper.getResponsivePadding(context).left,
                  right: ResponsiveHelper.getResponsivePadding(context).right,
                  bottom: ResponsiveHelper.getResponsivePadding(context).bottom,
                ),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: _magazines.length,
                itemBuilder: (context, index) {
                  final magazine = _magazines[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        magazine['name'] ?? 'Unknown Magazine',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: magazine['count'] != null
                          ? Text(
                              '${magazine['count']} entries',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            )
                          : null,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
