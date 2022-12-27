import "package:flutter/material.dart";
import "package:notepad/constants/app_strings.dart";
import "package:notepad/pages/tag_page.dart";
import "package:notepad/pages/trash_page.dart";
import "package:url_launcher/url_launcher.dart";

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int selected = -1;

  void changeSelected(int index) {
    setState(
      () {
        selected = index;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const SizedBox(
            height: 60,
            child: Center(
              child: Text(
                "NotePad",
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          const Divider(
            thickness: 5,
            indent: 10,
            endIndent: 10,
          ),
          ListTile(
            selected: selected == 0,
            leading: Icon(
              Icons.note,
              color: Colors.blue,
            ),
            title: const DrawerText(text: "Notes"),
            dense: true,
            onTap: () {
              changeSelected(0);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            selected: selected == 1,
            leading: const Icon(
              Icons.delete,
              color: Colors.blue,
            ),
            title: const DrawerText(text: "Trash"),
            dense: true,
            onTap: () {
              changeSelected(1);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrashPage(),
                ),
              );
            },
          ),
          ListTile(
            selected: selected == 2,
            leading: const Icon(
              Icons.tag,
              color: Colors.blue,
            ),
            title: const DrawerText(text: "Tags"),
            dense: true,
            onTap: () {
              changeSelected(2);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TagsPage(),
                ),
              );
            },
          ),
          const Divider(
            thickness: 3,
            indent: 10,
            endIndent: 10,
          ),
          ListTile(
            selected: selected == 3,
            leading: Icon(
              Icons.local_play,
              color: Colors.blue,
            ),
            title: const DrawerText(text: "Rate this App"),
            dense: true,
            onTap: () {
              changeSelected(3);
              launchUrl(
                Uri.parse(AppStrings.appUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            selected: selected == 4,
            leading: const Icon(
              Icons.local_mall,
              color: Colors.blue,
            ),
            title: const DrawerText(text: "More Apps"),
            dense: true,
            onTap: () {
              changeSelected(4);
              launchUrl(
                Uri.parse(AppStrings.publisherUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          ListTile(
            selected: selected == 5,
            leading: const Icon(
              Icons.description,
              color: Colors.blue,
            ),
            title: const DrawerText(text: "Privacy Policy"),
            dense: true,
            onTap: () {
              changeSelected(5);

              launchUrl(
                Uri.parse(AppStrings.policyUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          const Divider(
            thickness: 3,
            indent: 10,
            endIndent: 10,
          ),
        ],
      ),
    );
  }
}

class DrawerText extends StatelessWidget {
  const DrawerText({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
      softWrap: true,
    );
  }
}
