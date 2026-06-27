import os
import glob
import re

# 1. Replace 'POS Jamu' with 'Jamu Sehat'
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
    if 'POS Jamu' in content:
        content = content.replace('POS Jamu', 'Jamu Sehat')
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Updated {file}')

# 2. Fix dashboard_tab.dart _buildRecentActivitiesSection
dt_path = 'lib/screens/dashboard_tab.dart'
with open(dt_path, 'r', encoding='utf-8') as f:
    content = f.read()

# We want to replace the StreamBuilder part inside _buildRecentActivitiesSection
pattern = r'StreamBuilder<QuerySnapshot>\([\s\S]*?final docs = snapshot\.data!\.docs;'
replacement = '''Builder(
          builder: (context) {
            if (provider.recentTransactions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    "Belum ada data",
                    style: TextStyle(fontSize: 14, color: JamuTheme.textSecondary),
                  ),
                ),
              );
            }

            final txs = provider.recentTransactions.take(3).toList();'''
            
content = re.sub(pattern, replacement, content)

# Adjust ListView itemCount
content = content.replace('itemCount: docs.length,', 'itemCount: txs.length,')

# Adjust itemBuilder inner logic
pattern2 = r"final doc = docs\[index\];[\s\S]*?if \(data\['timestamp'\] != null\) \{[\s\S]*?\}"
replacement2 = '''final tx = txs[index];
                final items = tx.items ?? [];
                final double amount = tx.amount;
                final String timeStr = tx.timestamp;'''
content = re.sub(pattern2, replacement2, content)

# Adjust formatting logic
content = content.replace("final nama = e['nama_produk'] ?? '';", "final nama = e.name;")
content = content.replace("final qty = e['jumlah'] ?? 0;", "final qty = e.quantity;")
content = content.replace("final harga = e['harga'] ?? 0;", "final harga = e.price;")
content = content.replace("id: doc.id,", "id: tx.id,")

# Adjust mapping logic inside Column
content = content.replace('''final namaProduk = item['nama_produk'] ?? '';
                                  final jumlah = item['jumlah'] ?? 0;''', '''final namaProduk = item.name;
                                  final jumlah = item.quantity;''')

with open(dt_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated dashboard_tab.dart logic')
