import sys

with open('pubspec.yaml', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    new_lines.append(line)
    if line.startswith('dev_dependencies:'):
        new_lines.append('  flutter_launcher_icons: ^0.14.3\n')

# Append configuration
config = """
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.png"
  min_sdk_android: 21
"""
new_lines.append(config)

with open('pubspec.yaml', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print('Updated pubspec.yaml')
