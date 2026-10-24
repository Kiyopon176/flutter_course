import '../models/event.dart';

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _two(int value) => value.toString().padLeft(2, '0');

/// "18 Oct"
String formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]}';

/// "10:00"
String formatTime(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

/// "18 Oct, 10:00"
String formatDateTime(DateTime date) =>
    '${formatDate(date)}, ${formatTime(date.hour, date.minute)}';

String _span(Duration d) {
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  return '${d.inMinutes}m';
}

String countdownLabel(Countdown countdown) => switch (countdown) {
  Upcoming(:final remaining) => 'Starts in ${_span(remaining)}',
  Started(:final elapsed) => 'Started ${_span(elapsed)} ago',
  Ended() => 'Ended',
};
