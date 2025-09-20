import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_data.dart';
import 'core/routes/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'features/money_receive/presentation/bloc/money_receive_bloc.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/pending/presentation/bloc/pending_bloc.dart';

class PaySyncApp extends StatelessWidget {
  const PaySyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<ThemeCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<MoneyReceiveBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<HistoryBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<PendingBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'PaySync',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: state is ThemeLight ? ThemeMode.light : ThemeMode.dark,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
