// lib/pages/auth/auth_page.dart
import 'package:flutter/material.dart';
import 'package:hack_front/providers/auth_provider.dart';
import 'package:hack_front/providers/theme_provider.dart';
import 'package:hack_front/utils/responsive_util.dart';
import 'package:provider/provider.dart';

enum AuthMode { login, signup }

class AuthPage extends StatefulWidget {
  final AuthMode initialAuthMode;

  const AuthPage({super.key, this.initialAuthMode = AuthMode.login});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  // Add TickerProvider
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AuthMode _authMode;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  final String backgroundImageUrlDark =
      'https://images.pexels.com/photos/3137078/pexels-photo-3137078.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2';

  final String backgroundImageUrlLight =
      "https://images.pexels.com/photos/3778550/pexels-photo-3778550.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2";

  @override
  void initState() {
    super.initState();
    _authMode = widget.initialAuthMode;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward(); // Initial fade in
  }

  @override
  void didUpdateWidget(covariant AuthPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAuthMode != _authMode) {
      // This handles when the route changes (e.g. browser back/forward to /login or /signup)
      // and the AuthPage widget itself is rebuilt with a new initialAuthMode.
      _switchModeAndAnimate(widget.initialAuthMode);
    }
  }

  void _switchModeAndAnimate(AuthMode newMode) {
    if (_authMode == newMode) return;

    _animationController.reverse().then((_) {
      setState(() {
        _authMode = newMode;
        _formKey.currentState?.reset();
        _emailController.clear(); // Clear fields on mode switch
        _passwordController.clear();
        _confirmPasswordController.clear();
        Provider.of<AuthProvider>(context, listen: false).clearErrorMessage();
      });
      _animationController.forward();
    });
  }

  void _toggleAuthMode() {
    // This is called by the button press within the AuthPage
    final newMode = _authMode == AuthMode.login
        ? AuthMode.signup
        : AuthMode.login;
    _switchModeAndAnimate(newMode);

    // OPTIONAL: If you still want the URL to update when the user *clicks the toggle button*,
    // you would still need to inform the RouterDelegate here.
    // final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
    // if (newMode == AuthMode.signup) {
    //   routerDelegate.updateCurrentAuthScreenPathIntent(const SignupPath());
    // } else {
    //   routerDelegate.updateCurrentAuthScreenPathIntent(const LoginPath());
    // }
    // For the smoothest internal UX, you might choose NOT to update the URL on internal toggle,
    // and only rely on initial URL loading for the mode. This is a UX decision.
    // If you *do* update the URL here, the didUpdateWidget logic will also fire,
    // but _switchModeAndAnimate has a guard `if (_authMode == newMode) return;`
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (_authMode == AuthMode.login) {
        await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await authProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildActualForm(BuildContext context, AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _authMode == AuthMode.login ? 'Art Atlas Login' : 'Create Account',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            // ... (same as before)
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.grey.shade300),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Colors.grey.shade400,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            // ... (same as before)
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.grey.shade300),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade400),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (_authMode == AuthMode.signup && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          // AnimatedSwitcher for the Confirm Password field
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.vertical,
                  child: child,
                ),
              );
            },
            child: _authMode == AuthMode.signup
                ? Column(
                    // Wrap in column to give it a key for AnimatedSwitcher if needed
                    key: const ValueKey('signup_confirm_password'),
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: Colors.grey.shade300),
                          prefixIcon: Icon(
                            Icons.label_important,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (_authMode == AuthMode.signup &&
                              value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(
                    key: ValueKey('signup_empty_confirm'),
                  ), // Empty space when not in signup
          ),
          const SizedBox(height: 24),
          if (authProvider.status == AuthStatus.authenticating)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(_authMode == AuthMode.login ? 'Login' : 'Sign Up'),
            ),
          const SizedBox(height: 12),
          if (authProvider.errorMessage != null &&
              authProvider.status != AuthStatus.authenticating)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                authProvider.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          TextButton(
            onPressed: authProvider.status == AuthStatus.authenticating
                ? null
                : _toggleAuthMode,
            child: Text(
              _authMode == AuthMode.login
                  ? "Don't have an account? Sign Up"
                  : 'Already have an account? Login',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLargeScreen = !ResponsiveUtil.isMobile(context);

    // No longer need the WidgetsBinding.instance.addPostFrameCallback here
    // as didUpdateWidget handles external changes to initialAuthMode.

    Widget formUI = FadeTransition(
      opacity: _opacityAnimation,
      child: _buildActualForm(context, authProvider),
    );

    if (isLargeScreen) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: double.infinity,
                child: Image.network(
                  Provider.of<ThemeProvider>(context).isDarkMode
                      ? backgroundImageUrlDark
                      : backgroundImageUrlLight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey.shade800);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(/* ... loading ... */);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 20.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: formUI, // Use the animated form
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile layout
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              /* ... background image ... */
              child: Image.network(
                Provider.of<ThemeProvider>(context).isDarkMode
                    ? backgroundImageUrlDark
                    : backgroundImageUrlLight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.black);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox.shrink();
                },
              ),
            ),
            Positioned.fill(
              /* ... gradient overlay ... */
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      /* ... semi-transparent container ... */
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: formUI, // Use the animated form
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
