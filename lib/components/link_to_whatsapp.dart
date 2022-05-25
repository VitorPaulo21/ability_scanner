import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkToWhatsApp extends StatelessWidget {
  const LinkToWhatsApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(
          Uri.parse(
              "https://api.whatsapp.com/send?phone=553732321127&text=Ol%C3%A1%2C%20Tudo%20Bem%3F"),
          mode: LaunchMode.externalApplication),
      onLongPress: () async {
        Clipboard.setData(const ClipboardData(text: "(37)3232-1127"));

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Número Copiado"),
          ),
        );
        Navigator.of(context).pop();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.whatsapp,
            color: Colors.green,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "(37)3232-1127",
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
