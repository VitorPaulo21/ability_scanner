import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkToSite extends StatelessWidget {
  const LinkToSite({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse("https://www.abilityonline.com.br"),
        mode: LaunchMode.externalApplication,
      ),
      onLongPress: () async {
        Clipboard.setData(
            const ClipboardData(text: "https://www.abilityonline.com.br"));

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Link Copiado"),
          ),
        );
        Navigator.of(context).pop();
      },
      child: const Text(
        "www.abilityonline.com.br",
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}
