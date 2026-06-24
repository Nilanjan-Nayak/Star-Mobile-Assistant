import re

file_path = r'c:\Users\user\OneDrive\Documents\Nilanjan All Projects\Star projects Lab\mobile jar\Star\lib\pages\star_home.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace .withOpacity(x) with .withValues(alpha: x)
# Handle cases possibly with spaces like .withOpacity( 0.5 )
new_content = re.sub(r'\.withOpacity\s*\(\s*([^)]+)\s*\)', r'.withValues(alpha: \1)', content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print(f"Updated {file_path}")
