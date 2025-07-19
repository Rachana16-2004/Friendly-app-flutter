import 'package:app/pages/create_post_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 3D Hover Wrapper
class Hover3D extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const Hover3D({required this.child, required this.onPressed});

  @override
  _Hover3DState createState() => _Hover3DState();
}

class _Hover3DState extends State<Hover3D> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: isHovered
            ? (Matrix4.identity()..translate(0, -4, 0)..scale(1.02))
            : Matrix4.identity(),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: widget.child,
        ),
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isSignUp = false;
  bool isLoading = false;

  void _toggleForm() {
    setState(() {
      isSignUp = !isSignUp;
    });
  }

  Future<void> _submit() async {
    final supabase = Supabase.instance.client;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = isSignUp
          ? await supabase.auth.signUp(email: email, password: password)
          : await supabase.auth.signInWithPassword(email: email, password: password);

      final user = response.user;

      if (user != null) {
        print('✅ Auth successful for user ID: ${user.id}');

        if (isSignUp) {
          final insertResponse = await supabase.from('users').insert({
            'id': user.id,
            'email': email,
          });

          print('🗃️ User inserted into users table: $insertResponse');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CreatePostPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Check your email to confirm your account.'),
        ));
      }
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ ${e.message}'),
      ));
    } catch (e) {
      print('❌ Unknown error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ Unexpected error occurred.'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background image
          Positioned.fill(
            child: Image.asset(
              'assets/a.jpg', // ← Make sure this image exists in assets & declared in pubspec.yaml
              fit: BoxFit.cover,
            ),
          ),
          // ✅ Optional dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          // ✅ Auth box
          Center(
            child: SingleChildScrollView(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(0.02)
                  ..rotateY(-0.02),
                child: Container(
                  width: 360,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // ← semi-transparent
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isSignUp ? 'Sign Up' : 'Sign In',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        isLoading
                            ? CircularProgressIndicator()
                            : Hover3D(
                                onPressed: _submit,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueAccent.withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    isSignUp ? 'Sign Up' : 'Sign In',
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                        SizedBox(height: 12),
                        TextButton(
                          onPressed: _toggleForm,
                          child: Text(
                            isSignUp
                                ? 'Already have an account? Sign In'
                                : 'Don’t have an account? Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
