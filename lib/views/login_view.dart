import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/constants/app_managers.dart';
import 'package:planner_messenger/managers/local_manager.dart';
import 'package:planner_messenger/widgets/buttons/primary_app_button.dart';

import '../constants/app_images.dart';

import '../widgets/forms/text_fields.dart';

class LoginView extends StatefulWidget {
  final int? chatId;
  const LoginView({super.key, this.chatId});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController = TextEditingController();
  late final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await AppManagers.local.load();
      var username = AppManagers.local.getString(LocalManagerKey.username);
      var password = AppManagers.local.getString(LocalManagerKey.password);
      _emailController.text = username;
      _passwordController.text = password;
      AppControllers.auth.checkIsLogged(username, password);
    });
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      AppControllers.auth.login(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Theme.of(context).disabledColor,
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 30),
                  Text(
                    "Passenger",
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontSize: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Giriş yap",
                    style: Get.textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const SizedBox(height: 20),
                  const SizedBox(height: 30),
                  _buildEmailTextField(context),
                  const SizedBox(height: 15),
                  _buildPasswordTextField(context),
                  const SizedBox(height: 20),
                  PrimaryAppButton(text: "Login", onTap: _login),
                  const SizedBox(height: 15),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  CustomTextField _buildEmailTextField(BuildContext context) {
    return CustomTextField(
      hintText: "Email",
      textInputType: TextInputType.emailAddress,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return "Email is required field";
        }
        return null;
      },
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: SvgPicture.asset(
          DefaultImages.mail,
          color: Theme.of(context).disabledColor,
        ),
      ),
      suffixIcon: const SizedBox(),
      textEditingController: _emailController,
    );
  }

  CustomPasswordField _buildPasswordTextField(BuildContext context) {
    return CustomPasswordField(
      hintText: "Password",
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return "Password is required field";
        }
        return null;
      },
      widget: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: SvgPicture.asset(
          DefaultImages.lock,
          color: Theme.of(context).disabledColor,
        ),
      ),
      suffixIcon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: SvgPicture.asset(
          DefaultImages.eyeOff,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      textEditingController: _passwordController,
    );
  }
}
