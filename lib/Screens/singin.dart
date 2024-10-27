import 'package:flutter/material.dart';
import 'package:smart_gas/widgets/custom_scaffold.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(
      child: Text("Iniciar sesión"),
    );
  }
}
