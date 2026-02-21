import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'settings_service.dart';
import 'calendar_screen.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingService(),
      child: const ManawebApp(),
    ),
  );
}

class ManawebApp extends StatelessWidget {
  const ManawebApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingService = Provider.of<SettingService>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مناوب',
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: settingService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // --- التعديل: حماية مقياس الخطوط ---
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.25),
            ),
          ),
          child: child!,
        );
      },
      home: const CalendarScreen(),
    );
  }
}
