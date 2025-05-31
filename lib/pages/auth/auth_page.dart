// lib/pages/auth/auth_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart'; // For CupertinoIcons if used (like CupertinoIcons.lock_circle)
import 'package:flutter/material.dart';
import 'package:hack_front/providers/auth_provider.dart';
import 'package:hack_front/providers/theme_provider.dart';
import 'package:hack_front/routes/app_route_path.dart';
import 'package:hack_front/routes/app_router_delegate.dart';

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
      "https://images.pexels.com/photos/297494/pexels-photo-297494.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2";

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
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant AuthPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAuthMode != _authMode) {
      _switchModeAndAnimate(widget.initialAuthMode);
    }
  }

  void _switchModeAndAnimate(AuthMode newMode) {
    if (_authMode == newMode) return;
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _authMode = newMode;
          _formKey.currentState?.reset();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          Provider.of<AuthProvider>(context, listen: false).clearErrorMessage();
        });
        _animationController.forward();
      }
    });
  }

  void _toggleAuthMode() {
    final newMode = _authMode == AuthMode.login
        ? AuthMode.signup
        : AuthMode.login;

    final routerDelegate =
        Router.of(context).routerDelegate as AppRouterDelegate;
    if (newMode == AuthMode.signup) {
      routerDelegate.updateCurrentAuthScreenPathIntent(const SignupPath());
    } else {
      routerDelegate.updateCurrentAuthScreenPathIntent(const LoginPath());
    }
    _switchModeAndAnimate(newMode);
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
    final ThemeData theme = Theme.of(context);
    final Color onFormColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final Color hintFormColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final Color prefixIconFormColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    // Styling similar to Collection Page search bar
    InputDecoration formFieldDecoration({
      required String labelText,
      required IconData prefixIconData,
    }) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: hintFormColor,
          fontSize: 15,
        ), // Adjusted label
        hintText: labelText, // Use labelText as hintText as well
        hintStyle: TextStyle(
          color: hintFormColor.withOpacity(0.7),
          fontSize: 15,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 10.0),
          child: Icon(prefixIconData, color: prefixIconFormColor, size: 20),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 20.0,
        ), // Adjusted padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0), // Rounded like search bar
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        // Ensure background of text field is transparent if form container has color
        filled: true,
        fillColor: theme.colorScheme.surface.withOpacity(
          theme.brightness == Brightness.dark ? 0.1 : 0.5,
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _authMode == AuthMode.login
                ? 'Art Atlas'
                : 'Create Account', // Title changed for login
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              // Using displaySmall for less emphasis than displayLarge
              fontWeight: FontWeight.w300, // Lighter font weight
              color: onFormColor,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 40), // Increased spacing
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: onFormColor, fontSize: 16),
            decoration: formFieldDecoration(
              labelText: 'Email',
              prefixIconData: Icons.email_outlined,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20), // Adjusted spacing
          TextFormField(
            controller: _passwordController,
            style: TextStyle(color: onFormColor, fontSize: 16),
            decoration: formFieldDecoration(
              labelText: 'Password',
              prefixIconData: Icons.lock_outline,
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
                    key: const ValueKey('confirm_password_field'),
                    children: [
                      const SizedBox(height: 20), // Adjusted spacing
                      TextFormField(
                        controller: _confirmPasswordController,
                        style: TextStyle(color: onFormColor, fontSize: 16),
                        decoration: formFieldDecoration(
                          labelText: 'Confirm Password',
                          prefixIconData: CupertinoIcons.lock_circle,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (_authMode == AuthMode.signup) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(
                    key: ValueKey('no_confirm_password_field'),
                  ),
          ),
          const SizedBox(height: 30), // Adjusted spacing
          if (authProvider.status == AuthStatus.authenticating)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                ), // Taller button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ), // Rounded to match fields
                ),
              ),
              onPressed: _submitForm,
              child: Text(
                _authMode == AuthMode.login ? 'Login' : 'Sign Up',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          const SizedBox(height: 16),
          if (authProvider.errorMessage != null &&
              authProvider.status != AuthStatus.authenticating)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                authProvider.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
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
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.secondary,
              ), // Ensure themed color
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isLargeScreen = !ResponsiveUtil.isMobile(context);
    final ThemeData currentTheme = Theme.of(context);

    if (widget.initialAuthMode != _authMode &&
        authProvider.status != AuthStatus.authenticating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _switchModeAndAnimate(widget.initialAuthMode);
        }
      });
    }

    Widget formUI = FadeTransition(
      opacity: _opacityAnimation,
      child: _buildActualForm(context, authProvider),
    );

    final String currentBackgroundImageUrl = themeProvider.isDarkMode
        ? backgroundImageUrlDark
        : backgroundImageUrlLight; // Keep distinct background for light/dark if needed

    if (isLargeScreen) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: double.infinity,
                child: CachedNetworkImage(
                  // For desktop, always use the "dark" mode style image, or make it configurable
                  imageUrl: currentBackgroundImageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) {
                    return Container(
                      color: currentTheme.brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: currentTheme.scaffoldBackgroundColor,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 20.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: formUI,
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
      // Removed background image and gradient for mobile to match the reference light theme screenshot
      // Color formContainerColor = themeProvider.isDarkMode
      //     ? Colors.black.withOpacity(0.0) // Fully transparent if background is dark
      //     : Colors.white.withOpacity(0.0); // Fully transparent if background is light

      return Scaffold(
        backgroundColor:
            currentTheme.scaffoldBackgroundColor, // Use theme background
        body: Stack(
          // Stack is kept in case you want to re-add image/gradient later
          children: [
            // Positioned.fill(
            //   child: Image.network(
            //     currentBackgroundImageUrl,
            //     fit: BoxFit.cover,
            //     errorBuilder: (context, error, stackTrace) {
            //       return Container(color: currentTheme.scaffoldBackgroundColor);
            //     },
            //     loadingBuilder: (context, child, loadingProgress) {
            //       if (loadingProgress == null) return child;
            //       return const SizedBox.shrink();
            //     },
            //   ),
            // ),
            // Positioned.fill(
            //   child: Container(
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient( ... )
            //     ),
            //   ),
            // ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(
                  32.0,
                ), // Increased padding for mobile form
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.all(
                      24.0,
                    ), // Keep padding for form elements
                    decoration: BoxDecoration(
                      // color: formBackgroundColor, // No specific background for the form container itself
                      borderRadius: BorderRadius.circular(
                        12.0,
                      ), // Keep if you want rounded form edges
                      // No boxShadow if the container is transparent
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.15),
                      //     spreadRadius: 1,
                      //     blurRadius: 8,
                      //     offset: const Offset(0, 3),
                      //   ),
                      // ],
                    ),
                    child: formUI,
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
