import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'settings_service.dart';
import 'setup_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<SettingService>(context);
    String lang = Localizations.localeOf(context).languageCode;
    HijriCalendar.setLocal(lang);
    var hjNow = HijriCalendar.fromDate(
        DateTime.now().add(Duration(days: service.hijriAdjustment)));

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ar' ? "تقويم المناوبات" : "Shift Calendar"),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SetupScreen()))),
        ],
      ),
      // --- التعديل: استخدام SafeArea و SingleChildScrollView ---
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                color: Colors.blue.withOpacity(0.1),
                child: Text(
                    "${lang == 'ar' ? 'اليوم:' : 'Today:'} ${hjNow.toFormat("dd MMMM yyyy")}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17)),
              ),
              TableCalendar(
                locale: lang == 'ar' ? 'ar_SA' : 'en_US',
                firstDay: DateTime.utc(2010, 1, 1),
                lastDay: DateTime.utc(2045, 12, 31),
                focusedDay: DateTime.now(),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextFormatter: (date, locale) =>
                      DateFormat.yMMMM(locale).format(date),
                ),
                onDaySelected: (selectedDay, focusedDay) =>
                    _showDayDetails(context, selectedDay, service, lang),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) =>
                      _dayContainer(day, service.isWorkDay(day)),
                  todayBuilder: (context, day, focusedDay) =>
                      _dayContainer(day, service.isWorkDay(day), isToday: true),
                ),
              ),

              const SizedBox(height: 20), // بديل للـ Spacer لضمان التباعد

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegend(
                        Colors.blue.shade400, lang == 'ar' ? "دوام" : "Duty"),
                    const SizedBox(width: 30),
                    _buildLegend(
                        Colors.grey.shade200, lang == 'ar' ? "راحة" : "Off"),
                  ],
                ),
              ),
              const SizedBox(height: 20), // مساحة أمان سفلية
            ],
          ),
        ),
      ),
    );
  }

  void _showDayDetails(BuildContext context, DateTime date,
      SettingService service, String lang) {
    var hjSelected = HijriCalendar.fromDate(
        date.add(Duration(days: service.hijriAdjustment)));
    bool isWork = service.isWorkDay(date);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
            DateFormat.yMMMMd(lang == 'ar' ? 'ar_SA' : 'en_US').format(date),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hjSelected.toFormat("dd MMMM yyyy"),
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 15),
            Text(
                lang == 'ar'
                    ? (isWork ? "الحالة: دوام 🟦" : "الحالة: راحة ⬜")
                    : (isWork ? "Duty 🟦" : "Off ⬜"),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _dayContainer(DateTime day, bool work, {bool isToday = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: work ? Colors.blue.shade400 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: Colors.orange, width: 2) : null,
      ),
      child: Text('${day.day}',
          style: TextStyle(
              color: work ? Colors.white : Colors.black,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _buildLegend(Color color, String label) => Row(children: [
        Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(label)
      ]);
}
