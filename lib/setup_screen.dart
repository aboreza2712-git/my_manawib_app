import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_service.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<SettingService>(context);
    String lang = Localizations.localeOf(context).languageCode;
    final isDarkMode = service.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ar' ? "الإعدادات" : "Settings"),
      ),
      // --- الحل البرمجي للمشكلة الموضحة في الصورة ---
      // SafeArea يضمن عدم تداخل النصوص مع أزرار التنقل في أسفل الهاتف
      body: SafeArea(
        bottom: true, // تفعيل الحماية من الجهة السفلية تحديداً
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), // ببادئة جانبية
          children: [
            // --- قسم تاريخ تفعيل النظام ---
            _buildSectionTitle(
                lang == 'ar' ? "تاريخ تفعيل النظام" : "System Activation"),
            ListTile(
              tileColor:
                  const Color.fromARGB(255, 189, 228, 242).withOpacity(0.05),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.calendar_today,
                  color: Color.fromARGB(255, 228, 178, 102)),
              title: Text(lang == 'ar' ? "تاريخ بداية الدوام" : "Start Date"),
              subtitle: Text(
                  "${service.startDate.year}/${service.startDate.month}/${service.startDate.day}"),
              onTap: () async {
                final d = await showDatePicker(
                    context: context,
                    initialDate: service.startDate,
                    firstDate: DateTime(2010),
                    lastDate: DateTime(2045));
                if (d != null) {
                  service.updateShiftSettings(
                      service.workDays, service.restDays, d);
                }
              },
            ),
            const Divider(height: 30),

            // --- قسم البحث التاريخي ---
            _buildSectionTitle(
                lang == 'ar' ? "البحث عن يوم دوام سابق" : "History Search"),
            ListTile(
              tileColor: Colors.blue.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.search, color: Colors.blue),
              title: Text(lang == 'ar'
                  ? "ادخل التاريخ المطلوب"
                  : "Search specific day"),
              onTap: () async {
                final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2050));
                if (d != null) {
                  _showSearchResult(context, d, service.isWorkDay(d), lang);
                }
              },
            ),
            const Divider(),

            // --- قسم نظام المناوبة ---
            _buildSectionTitle(lang == 'ar' ? "نظام المناوبة" : "Shift System"),
            _shiftTile(
                lang == 'ar'
                    ? '1/3 (يوم عمل/3 ايام راحة)'
                    : '1/3 (1 Work/3 Rest)',
                1,
                3,
                service),
            _shiftTile(
                lang == 'ar' ? '1/1 (يوم عمل/يوم راحة)' : '1/1 (1 Work/1 Rest)',
                1,
                1,
                service),
            const Divider(),

            // --- تفضيلات الواجهة ---
            SwitchListTile(
                title: Text(lang == 'ar' ? "الوضع الليلي" : "Dark Mode"),
                value: service.isDarkMode,
                onChanged: (v) => service.toggleTheme()),

            ListTile(
              title:
                  Text(lang == 'ar' ? "تصحيح التاريخ الهجري" : "Hijri Adjust"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => service
                          .updateHijriAdjustment(service.hijriAdjustment - 1)),
                  Text("${service.hijriAdjustment}"),
                  IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => service
                          .updateHijriAdjustment(service.hijriAdjustment + 1)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(thickness: 1),

            // --- قسم "حول التطبيق" ---
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Icon(Icons.info_outline,
                    color: isDarkMode
                        ? Colors.blue.shade300
                        : Colors.blue.shade800),
                title: Text(
                  lang == 'ar' ? "حول التطبيق" : "About App",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.blue.shade300
                        : Colors.blue.shade800,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    child: Column(
                      children: [
                        Text(
                          lang == 'ar'
                              ? "تطبيق 'مُناوب' (الإصدار 1.0.0) هو أداة ذكية صُممت خصيصاً لمساعدة الموظفين والكوادر التي تعمل بنظام المناوبات المتغيرة. يهدف التطبيق إلى تسهيل تنظيم الوقت عبر جدولة دقيقة لنوبات العمل والراحة وتوقعها لسنوات قادمة بناءً على أنماط مخصصة، مما يضمن للمستخدم رؤية واضحة لمستقبله المهني والاجتماعي."
                              : "'Monawab' app (Version 1.0.0) is a smart tool specifically designed to assist employees and shift-based workers.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87),
                        ),
                        const SizedBox(height: 15),
                        Center(
                            child: Text("© 2026 Developed by yousif",
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- هذه هي الإضافة الأهم لحل مشكلة الصورة ---
            // نضع مساحة فارغة كبيرة في الأسفل لتمكين المستخدم من رفع النص فوق الأزرار
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blue)));

  Widget _shiftTile(String t, int w, int r, SettingService s) => RadioListTile(
      title: Text(t),
      value: true,
      groupValue: s.workDays == w && s.restDays == r,
      onChanged: (v) => s.updateShiftSettings(w, r, s.startDate));

  void _showSearchResult(
      BuildContext context, DateTime date, bool isWork, String lang) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            title: Text(lang == 'ar' ? "نتيجة البحث" : "Result"),
            content: Text(
                "${date.day}/${date.month}/${date.year}\n${isWork ? (lang == 'ar' ? "يوم دوام 🟦" : "Duty Day") : (lang == 'ar' ? "يوم راحة ⬜" : "Off Day")}")));
  }
}
