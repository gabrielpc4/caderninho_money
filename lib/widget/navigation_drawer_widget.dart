import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../theme_model.dart';
import '../hex_color.dart';

class NavigationDrawerWidget extends StatefulWidget {
  ThemeModel? themeNotifier;
  NavigationDrawerWidget(this.themeNotifier);
  @override
  State<NavigationDrawerWidget> createState() =>
      _NavigationDrawerWidgetState(themeNotifier);
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  ThemeModel? themeNotifier;
  _NavigationDrawerWidgetState(this.themeNotifier);
  final MoneyMaskedTextController budgetTextEditingController =
      MoneyMaskedTextController(leftSymbol: 'R\$ ');

  Color pickerColor = const Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    budgetTextEditingController.text = 300.toStringAsFixed(2);
    return Drawer(
      child: Container(
        color: HexColor(themeNotifier?.appColor ?? "FFE91E63"),
        child: ListView(
          children: <Widget>[
            const ListTile(
              title: Text("Olá Marcela",
                  style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
            buildMenuItem(
              text: "Budget mensal",
              icon: Icons.attach_money,
              trailing: Flexible(
                child: SizedBox(
                  width: 100,
                  child: TextField(
                    controller: budgetTextEditingController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            buildMenuItem(
              text: "Cor do App",
              icon: Icons.format_paint,
              trailing: ElevatedButton(
                child: const Text('Alterar'),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: pickerColor,
                              onColorChanged: changeColor,
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('Got it'),
                              onPressed: () {
                                var newColor =
                                    pickerColor.toString().substring(8, 16);
                                themeNotifier?.appColor = newColor;
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildMenuItem({
  required String text,
  required IconData icon,
  required Widget trailing,
}) {
  const color = Colors.white;

  return ListTile(
    trailing: trailing,
    leading: Icon(icon, color: color),
    title: Text(text, style: const TextStyle(color: color)),
  );
}
