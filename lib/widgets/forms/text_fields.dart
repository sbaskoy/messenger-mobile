// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController textEditingController;
  final String? Function(String? value)? validator;
  final TextInputType? textInputType;
  final int? minLines;
  final int? maxLines;
  final bool? autoFocus;
  const CustomTextField({
    Key? key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    required this.textEditingController,
    this.suffixIcon,
    this.validator,
    this.textInputType,
    this.minLines,
    this.maxLines,
    this.autoFocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      validator: validator,
      keyboardType: textInputType,
      minLines: minLines,
      maxLines: maxLines,
      autofocus: autoFocus ?? false,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelText: labelText,
        hintText: hintText,
      ),
    );
  }
}

class CustomTextFieldWithoutPrefix extends StatelessWidget {
  final String hintText;
  final String labelText;
  final Widget suffixIcon;
  final TextEditingController textEditingController;
  final bool autoFocus;
  const CustomTextFieldWithoutPrefix({
    Key? key,
    required this.hintText,
    required this.labelText,
    required this.textEditingController,
    required this.suffixIcon,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autoFocus,
      controller: textEditingController,
      style: Theme.of(context).textTheme.bodyText1!.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        labelText: labelText,
        labelStyle: Theme.of(context).textTheme.labelSmall,
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.labelSmall,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).disabledColor,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).disabledColor,
          ),
        ),
      ),
    );
  }
}

class CustomPasswordField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final Widget widget;
  final Widget suffixIcon;
  final TextEditingController textEditingController;
  final String? Function(String? value)? validator;
  const CustomPasswordField(
      {Key? key,
      this.hintText,
      this.labelText,
      required this.widget,
      required this.textEditingController,
      required this.suffixIcon,
      this.validator})
      : super(key: key);

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _showPassword = true;

  void _change() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _showPassword,
      controller: widget.textEditingController,
      validator: widget.validator,
      decoration: InputDecoration(
        prefixIcon: widget.widget,
        suffixIcon: InkWell(
          onTap: _change,
          child: Icon(
            !_showPassword ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).disabledColor,
          ),
        ),
        labelText: widget.labelText,
        hintText: widget.hintText,
      ),
    );
  }
}
