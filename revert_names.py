import os

files_to_check = [
    'lib/providers/auth_provider.dart',
    'lib/screens/dashboard_screen.dart',
    'lib/screens/dashboard_tab.dart',
    'lib/screens/login_screen.dart',
    'lib/screens/privacy_policy_screen.dart',
    'lib/screens/store_info_screen.dart',
]

for file in files_to_check:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    if 'Jamu Sehat' in content:
        content = content.replace('Jamu Sehat', 'POS Jamu')
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Reverted {file}')

# AndroidManifest.xml
android_manifest = 'android/app/src/main/AndroidManifest.xml'
with open(android_manifest, 'r', encoding='utf-8') as f:
    content = f.read()
if 'android:label="project_ta"' in content:
    content = content.replace('android:label="project_ta"', 'android:label="Jamu Sehat"')
elif 'android:label="POS Jamu"' in content:
    content = content.replace('android:label="POS Jamu"', 'android:label="Jamu Sehat"')
with open(android_manifest, 'w', encoding='utf-8') as f:
    f.write(content)

# Info.plist
info_plist = 'ios/Runner/Info.plist'
with open(info_plist, 'r', encoding='utf-8') as f:
    content = f.read()
content = content.replace('<string>project_ta</string>', '<string>Jamu Sehat</string>')
with open(info_plist, 'w', encoding='utf-8') as f:
    f.write(content)

print('Updated Android and iOS app names')
