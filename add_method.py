import sys

# Read the file
with open(r'd:\flutter projects\anima_app\lib\screens\anime_detail_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the last closing brace
last_brace_index = content.rfind('}')

# Method to add
method = '''
  Widget _buildActionButtons(bool isDark) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await UrlLauncherHelper.openMyAnimeListPage(_anime.malId);
        } catch (e) {
          if (mounted) {
            UrlLauncherHelper.showLaunchError(
              context,
              'Could not open MyAnimeList',
            );
          }
        }
      },
      icon: const Icon(Icons.open_in_new, size: 20),
      label: const Text('View on MyAnimeList'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E51A2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
'''

# Insert the method before the last closing brace
new_content = content[:last_brace_index] + method + '\n' + content[last_brace_index:]

# Write back
with open(r'd:\flutter projects\anima_app\lib\screens\anime_detail_page.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Method added successfully!")
