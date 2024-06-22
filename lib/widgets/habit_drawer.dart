import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';

class HabitDrawer extends StatelessWidget {
  const HabitDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Drawer(
      backgroundColor: themeData.colorScheme.background,
      child: Center(
        child: CupertinoSwitch(
          value: themeProvider.isDarkMode,
          onChanged: (_) => themeProvider.toggleTheme(),
        ),
      ),
    );
  }
}
