import 'package:flutter/material.dart';
import '../../../../core/consts/app_themes.dart';
import '../../../../core/widgets/premium_widgets.dart';

class AuthLayout extends StatelessWidget {
  final String title, subtitle;
  final Widget form;
  final bool back;
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.back = false,
  });
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 205,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFB49BFF),
                          AppThemes.purple,
                          Color(0xFF4E31AB),
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(260, 38),
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (back)
                          Positioned(
                            left: 10,
                            top: 6,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        const Positioned(
                          right: -25,
                          top: -35,
                          child: Icon(
                            Icons.circle_outlined,
                            size: 210,
                            color: Colors.white12,
                          ),
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: TgMark(size: 100),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: dark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 30),
                        form,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
