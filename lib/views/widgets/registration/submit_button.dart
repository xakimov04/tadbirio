import 'package:flutter/material.dart';

class SubmitButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const SubmitButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() {
        _isButtonPressed = true;
      }),
      onTapUp: (_) => setState(() {
        _isButtonPressed = false;
      }),
      onTapCancel: () => setState(() {
        _isButtonPressed = false;
      }),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        width: _isButtonPressed
            ? MediaQuery.of(context).size.width - 30
            : MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: _isButtonPressed ? Colors.teal.shade700 : Colors.teal,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            if (!_isButtonPressed)
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
