import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/diagnose_provider.dart';
import 'screens/home_shell.dart';
import 'services/api_service.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OrchardAdvisoryApp());
}

class OrchardAdvisoryApp extends StatelessWidget {
  const OrchardAdvisoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (context) => DiagnoseProvider(context.read<ApiService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Orchard Advisory',
        debugShowCheckedModeBanner: false,
        theme: buildOrchardTheme(),
        home: const HomeShell(),
      ),
    );
  }
}
