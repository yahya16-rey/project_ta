import re

with open('lib/screens/transaction_history_screen.dart', 'r') as f:
    content = f.read()

# 1. Update filters
content = content.replace("final List<String> _filters = ['Harian', 'Bulanan', 'Tahunan', 'Semua'];", "final List<String> _filters = ['Harian', 'Mingguan', 'Bulanan', 'Tahunan', 'Semua'];")

# 2. Add _isSameWeek
is_same_week = """  bool _isSameWeek(DateTime d1, DateTime d2) {
    final startOfWeek1 = d1.subtract(Duration(days: d1.weekday - 1));
    final startOfWeek2 = d2.subtract(Duration(days: d2.weekday - 1));
    return startOfWeek1.year == startOfWeek2.year && startOfWeek1.month == startOfWeek2.month && startOfWeek1.day == startOfWeek2.day;
  }

  bool _isSameDay"""
content = content.replace("  bool _isSameDay", is_same_week)

# 3. Update _filterTransactions logic
old_switch = """      switch (_selectedFilterIndex) {
        case 0: // Harian
          return _isSameDay(date, now);
        case 1: // Bulanan
          return _isSameMonth(date, now) || _isSameMonth(date, DateTime(now.year, now.month - 1, 1));
        case 2: // Tahunan
          return _isSameYear(date, now);
        case 3: // Semua
        default:
          return true;
      }"""
new_switch = """      switch (_selectedFilterIndex) {
        case 0: // Harian
          return _isSameDay(date, now);
        case 1: // Mingguan
          return _isSameWeek(date, now);
        case 2: // Bulanan
          return _isSameYear(date, now); // Ambil semua tahun ini untuk di-group
        case 3: // Tahunan
          return true; // Ambil semua untuk di-group
        case 4: // Semua
        default:
          return true;
      }"""
content = content.replace(old_switch, new_switch)

# 4. Update the listItems logic in build()
old_list_items = """          final listItems = [];
          if (_selectedFilterIndex == 1) { // Bulanan
            final now = DateTime.now();
            final prevMonth = DateTime(now.year, now.month - 1, 1);
            
            bool addedCurrentHeader = false;
            bool addedPrevHeader = false;

            for (var doc in filteredDocs) {
              final date = _getDate(doc);
              if (_isSameMonth(date, now)) {
                if (!addedCurrentHeader) {
                  listItems.add('Bulan Saat Ini');
                  addedCurrentHeader = true;
                }
                listItems.add(doc);
              } else if (_isSameMonth(date, prevMonth)) {
                if (!addedPrevHeader) {
                  listItems.add('Bulan Sebelumnya');
                  addedPrevHeader = true;
                }
                listItems.add(doc);
              }
            }
          } else {
            listItems.addAll(filteredDocs);
          }

          return ListView.builder("""

new_list_items = """          final listItems = [];
          if (_selectedFilterIndex == 2) { // Bulanan
             final List<String> monthNames = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
             for (int i = 12; i >= 1; i--) {
                listItems.add('${monthNames[i-1]} ${DateTime.now().year}');
                bool hasItem = false;
                for (var doc in filteredDocs) {
                   if (_getDate(doc).month == i) {
                      listItems.add(doc);
                      hasItem = true;
                   }
                }
                if (!hasItem) {
                   listItems.add('EMPTY_STATE');
                }
             }
          } else if (_selectedFilterIndex == 3) { // Tahunan
             int minYear = DateTime.now().year;
             int maxYear = DateTime.now().year;
             for (var doc in filteredDocs) {
                int y = _getDate(doc).year;
                if (y < minYear) minYear = y;
                if (y > maxYear) maxYear = y;
             }
             for (int y = maxYear; y >= minYear; y--) {
                listItems.add('Tahun $y');
                bool hasItem = false;
                for (var doc in filteredDocs) {
                   if (_getDate(doc).year == y) {
                      listItems.add(doc);
                      hasItem = true;
                   }
                }
                if (!hasItem) {
                   listItems.add('EMPTY_STATE');
                }
             }
          } else {
            listItems.addAll(filteredDocs);
          }

          return ListView.builder("""
content = content.replace(old_list_items, new_list_items)


# 5. Handle EMPTY_STATE in itemBuilder
old_item_builder = """            itemBuilder: (context, index) {
              final item = listItems[index];
              if (item is String) {"""
new_item_builder = """            itemBuilder: (context, index) {
              final item = listItems[index];
              if (item == 'EMPTY_STATE') {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('Belum ada transaksi di periode ini.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                );
              } else if (item is String) {"""
content = content.replace(old_item_builder, new_item_builder)

with open('lib/screens/transaction_history_screen.dart', 'w') as f:
    f.write(content)
print("Updated successfully.")
