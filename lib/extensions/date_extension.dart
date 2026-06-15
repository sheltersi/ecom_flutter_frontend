extension DateTimeFormatting on String {
  /// Parses this ISO-8601 string and returns a formatted date like "14 Jun 2025".
  String toFormattedDate() {
    try {
      final dt = DateTime.parse(this);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return this;
    }
  }

  /// Parses this ISO-8601 string and returns a formatted date+time like "14 Jun 2025 at 14:30".
  String toFormattedDateTime() {
    try {
      final dt = DateTime.parse(this);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year} at $hour:$minute';
    } catch (_) {
      return this;
    }
  }
}
