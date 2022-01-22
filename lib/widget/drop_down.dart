import 'package:flutter/material.dart';

class DropDownColorPicker extends StatefulWidget {
  const DropDownColorPicker({Key? key}) : super(key: key);

  @override
  State<DropDownColorPicker> createState() => _DropDownColorPickerState();
}

class _DropDownColorPickerState extends State<DropDownColorPicker> {
  final items = ['Vermelho', 'Verde', 'Azul'];
  String selectedValue = 'Azul';
  var appColors = {
    "Vermelho": Colors.red,
    "Verde": Colors.green,
    "Azul": Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(0)),

      // dropdown below..
      child: DropdownButton<String>(
        value: selectedValue,
        onChanged: (String? newValue) =>
            setState(() => selectedValue = newValue ?? ""),
        items: items
            .map<DropdownMenuItem<String>>((String value) =>
                DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: appColors[value] ?? Colors.black),
                  ),
                ))
            .toList(),

        // add extra sugar..
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 42,
        underline: const SizedBox(),
      ),
    );
  }
}
