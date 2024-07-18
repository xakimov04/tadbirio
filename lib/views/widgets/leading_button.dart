import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LeadingButton extends StatelessWidget {
  const LeadingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            const BoxShadow(
              color: Colors.transparent,
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, -3),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: .5,
              blurRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }
}
