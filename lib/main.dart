import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'injection/injection_container.dart' as di;
import 'core/services/background_service_manager.dart';
import 'presentation/bloc/permission/permission_bloc.dart';
import 'presentation/pages/permission_check_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependency injection
  await di.init();

  // Initialize background service manager
  final backgroundServiceManager = di.sl<BackgroundServiceManager>();
  await backgroundServiceManager.initialize();

  runApp(const PaySyncApp());
}

class PaySyncApp extends StatelessWidget {
  const PaySyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaySync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => di.sl<PermissionBloc>()..add(CheckPermissionsEvent()),
        child: const PermissionCheckPage(),
      ),
    );
  }
}
