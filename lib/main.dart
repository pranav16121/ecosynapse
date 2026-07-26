import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/routes/router.dart';
import 'app/theme/theme.dart';
import 'core/state/auth_state.dart';
import 'core/state/resident_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => ResidentState()),
      ],
      child: const EcoSynapseApp(),
    ),
  );
}

class EcoSynapseApp extends StatelessWidget {
  const EcoSynapseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EcoSynapse',
      debugShowCheckedModeBanner: false,
      theme: EcoTheme.light,
      darkTheme: EcoTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
