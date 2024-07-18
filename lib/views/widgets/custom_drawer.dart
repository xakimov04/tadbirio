import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tadbirio/bloc/auth/auth_cubit.dart';
import 'package:tadbirio/views/screens/my_events/my_events.dart';
import 'package:tadbirio/views/screens/profile/profile_screen.dart';
import 'package:tadbirio/views/screens/registration_screen/login_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _name = '';
  String _email = '';
  String _imageUrl = '';
  String _surname = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'No name';
      _email = prefs.getString('email') ?? 'No email';
      _imageUrl = prefs.getString('image_url') ?? '';
      _surname = prefs.getString('surname') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const Gap(70),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: _imageUrl.isNotEmpty
                      ? NetworkImage(_imageUrl)
                      : const AssetImage('assets/icons/person_user.png'),
                ),
                const Gap(10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$_name $_surname",
                      style: TextStyle(
                        color: AdaptiveTheme.of(context).mode ==
                                AdaptiveThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _email,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 5,
            color: Colors.grey,
          ),
          Expanded(
            child: Column(
              children: [
                DrawerButton(
                  image: 'plan',
                  title: "Mening tadbirlarim",
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoModalPopupRoute(
                        builder: (context) => const MyEvents(),
                      ),
                    ).then((_) => _loadUserData());
                  },
                ),
                DrawerButton(
                  image: 'person',
                  title: "Profil ma'lumotlari",
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoModalPopupRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ).then((_) => _loadUserData());
                  },
                ),
                DrawerButton(
                  image: 'translate',
                  title: "Tillarni o'zgartirsh",
                  onTap: () {},
                ),
                DrawerButton(
                  image: 'sun',
                  title: "Tungi/Kunduzgi holat",
                  onTap: () {
                    if (AdaptiveTheme.of(context).mode ==
                        AdaptiveThemeMode.dark) {
                      AdaptiveTheme.of(context).setLight();
                    } else {
                      AdaptiveTheme.of(context).setDark();
                    }
                  },
                ),
                const Spacer(),
                DrawerButton(
                  image: 'log_out',
                  title: "Chiqish",
                  onTap: () {
                    context.read<AuthCubit>().signOut();
                    _clearPreferences();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  select: true,
                ),
                const Gap(30),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DrawerButton extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback? onTap;
  final bool select;

  const DrawerButton({
    super.key,
    required this.image,
    required this.title,
    required this.onTap,
    this.select = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/$image.png",
                    width: 25,
                    height: 25,
                    color:
                        AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                  ),
                  const Gap(15),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      color: select
                          ? Colors.red
                          : AdaptiveTheme.of(context).mode ==
                                  AdaptiveThemeMode.dark
                              ? Colors.white
                              : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            select
                ? const SizedBox()
                : IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
          ],
        ),
      ),
    );
  }
}
