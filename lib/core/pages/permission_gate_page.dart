import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/permission_service.dart';
import '../../presentation/pages/home_page.dart';

class PermissionGatePage extends ConsumerStatefulWidget {
  const PermissionGatePage({super.key});

  @override
  ConsumerState<PermissionGatePage> createState() => _PermissionGatePageState();
}

class _PermissionGatePageState extends ConsumerState<PermissionGatePage> with WidgetsBindingObserver {
  bool _isLoading = true;
  PermissionStatus _currentStatus = PermissionStatus.smsPermissionDenied;
  bool _showRetryButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This method is called when app resumes from background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Small delay to ensure user has finished with settings
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _checkPermissions();
        }
      });
    }
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
      _showRetryButton = false;
    });

    // Small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    final status = await PermissionService.checkAllPermissions();

    setState(() {
      _currentStatus = status;
      _isLoading = false;
    });

    // If all permissions granted, navigate to main app
    if (status == PermissionStatus.allGranted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  Future<void> _requestSmsPermissions() async {
    setState(() {
      _isLoading = true;
    });

    await PermissionService.requestSmsPermissions();

    // Wait a bit for permission dialog to close
    await Future.delayed(const Duration(milliseconds: 1000));

    // Always recheck permissions regardless of the returned value
    await _checkPermissions();
  }

  Future<void> _requestDefaultSmsApp() async {
    setState(() {
      _isLoading = true;
    });

    await PermissionService.requestDefaultSmsApp();

    // Don't immediately recheck - wait for app to resume
    setState(() {
      _isLoading = false;
    });

    // Show instruction to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select PaySync from the list and return to the app'),
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.message,
                  size: 60,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),

              const SizedBox(height: 32),

              // App Name
              Text(
                'PaySync',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'SMS Management App',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 48),

              // Permission Status Card
              _buildPermissionCard(),

              const SizedBox(height: 32),

              // Action Button
              if (_isLoading)
                const CircularProgressIndicator()
              else
                _buildActionButton(),

              if (_showRetryButton) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _checkPermissions,
                  child: const Text(' Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard() {
    IconData icon;
    String title;
    String description;
    Color iconColor;

    switch (_currentStatus) {
      case PermissionStatus.smsPermissionDenied:
        icon = Icons.sms;
        title = 'SMS Permissions Required';
        description = 'This app needs SMS permissions to read and manage your messages.';
        iconColor = Theme.of(context).colorScheme.error;
        break;
      case PermissionStatus.notDefaultApp:
        icon = Icons.home;
        title = 'Set as Default SMS App';
        description = 'Please set PaySync as your default SMS app to continue.';
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case PermissionStatus.allGranted:
        icon = Icons.check_circle;
        title = 'All Set!';
        description = 'All permissions granted. Loading your messages...';
        iconColor = Colors.green;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    String buttonText;
    VoidCallback? onPressed;

    switch (_currentStatus) {
      case PermissionStatus.smsPermissionDenied:
        buttonText = 'Grant SMS Permissions';
        onPressed = _requestSmsPermissions;
        break;
      case PermissionStatus.notDefaultApp:
        buttonText = 'Set as Default SMS App';
        onPressed = _requestDefaultSmsApp;
        break;
      case PermissionStatus.allGranted:
        buttonText = 'Loading...';
        onPressed = null;
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
