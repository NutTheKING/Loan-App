import 'package:intl/intl.dart';

class TextFormat {
  // ----------------------------
  // 📅 DATE FORMATTERS
  // ----------------------------

  /// Convert yyyy-MM-dd to dd/MMM/yyyy
  String dateYMDToDMY(String date) {
    final local = DateTime.parse(date).toLocal();
    return DateFormat("dd/MMM/yyyy").format(local);
  }

  /// Format full readable date: 25 December 2025
  String toReadableDate(String date) {
    final d = DateTime.parse(date);
    return DateFormat("dd MMMM yyyy").format(d);
  }

  /// Format: MM/dd/yyyy
  String dateUSA(String date) {
    final d = DateTime.parse(date);
    return DateFormat("MM/dd/yyyy").format(d);
  }

  /// Format: dd-MM-yyyy
  String dateDash(String date) {
    final d = DateTime.parse(date);
    return DateFormat("dd-MM-yyyy").format(d);
  }

  /// Relative time: "5 mins ago"
  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";

    return DateFormat("dd/MM/yyyy").format(date);
  }

  // ----------------------------
  // ⏰ TIME FORMATTERS
  // ----------------------------

  /// Convert 24h → 12h (hh:mm a)
  String formatTime12h(String time) {
    final t = DateTime.parse(time);
    return DateFormat("hh:mm a").format(t);
  }

  /// Convert to 24h format (HH:mm)
  String formatTime24h(String time) {
    final t = DateTime.parse(time);
    return DateFormat("HH:mm").format(t);
  }

  // ----------------------------
  // 💰 MONEY FORMATTERS
  // ----------------------------

  /// Format money with commas and currency
  String money(double amount, {String currency = "\$"}) {
    final formatter = NumberFormat("#,##0.00");
    return "$currency${formatter.format(amount)}";
  }

  /// Khmer currency formatting example
  // String moneyKHR(num amount) {
  //   final formatter = NumberFormat("#,###");
  //   return "${formatter.format(amount)}៛";
  // }

  // ----------------------------
  // 📞 PHONE FORMATTERS
  // ----------------------------

  /// Format phone: 012345678 → 012 345 678
  String phone(String number) {
    number = number.replaceAll(" ", "");
    return number.replaceAllMapped(RegExp(r".{3}"), (m) => "${m.group(0)} ");
  }

  /// Hide middle of phone number: 012***5678
  String securePhone(String phone) {
    if (phone.length < 7) return phone;
    return phone.replaceRange(3, phone.length - 4, "****");
  }

  // ----------------------------
  // 🔢 NUMBER FORMATTERS
  // ----------------------------

  /// Add commas to number
  // String number(num value) {
  //   return NumberFormat("#,###").format(value);
  // }

  /// Convert to short form: 1.2K, 3.4M
  String shortNumber(num value) {
    if (value >= 1000000000) {
      return "${(value / 1000000000).toStringAsFixed(1)}B";
    } else if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    }
    return value.toString();
  }

  // ----------------------------
  // 📝 OTHER HELPER FORMATTERS
  // ----------------------------

  /// Capitalize first letter
  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Uppercase words: hello world → Hello World
  String titleCase(String text) {
    return text
        .split(" ")
        .map((w) {
          if (w.isEmpty) return w;
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .join(" ");
  }
}
