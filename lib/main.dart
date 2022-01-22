import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'widget/navigation_drawer_widget.dart';
import 'theme_model.dart';
import 'hex_color.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
          builder: (context, ThemeModel themeNotifier, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
              // or from RGB

              primary: HexColor(themeNotifier.appColor),
              secondary: const Color(0xFFFFFFFF),
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: const MyHomePage(
            title: "Caderninho Money",
          ),
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Comprinha {
  String date;
  String nome;
  double valor;
  Comprinha(this.date, this.nome, this.valor);

  Comprinha.fromJson(Map<String, dynamic> json)
      : date = json['date'],
        nome = json['nome'],
        valor = json['valor'];

  static Map<String, dynamic> toMap(Comprinha comprinha) => {
        'date': comprinha.date,
        'nome': comprinha.nome,
        'valor': comprinha.valor,
      };

  static String encode(List<Comprinha> comprinhas) => json.encode(
        comprinhas
            .map<Map<String, dynamic>>(
                (comprinha) => Comprinha.toMap(comprinha))
            .toList(),
      );

  static List<Comprinha> decode(String comprinhas) =>
      (json.decode(comprinhas) as List<dynamic>)
          .map<Comprinha>((item) => Comprinha.fromJson(item))
          .toList();
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

String formatDate(DateTime date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(date);
}

String formatDate2(DateTime date) {
  List<String> monthName = [
    "Janeiro",
    "Fevereiro",
    "Março",
    "Abril",
    "Maio",
    "Junho",
    "Julho",
    "Agosto",
    "Setembro",
    "Outubro",
    "Novembro",
    "Dezembro"
  ];
  return '${date.day} de ${monthName[date.month + 1]} de ${date.year}';
}

class _MyHomePageState extends State<MyHomePage> {
  int daysInMonth = 30;
  Comprinha novaComprinha = Comprinha("", "", 0);
  List<Comprinha> comprinhas = [];
  final double defaultBudget = 300;
  double _budget = 300;
  double moneyLeft = 300;
  double available = 0;
  var controller = MoneyMaskedTextController(leftSymbol: 'R\$ ');
  var novaComprinhaController = MoneyMaskedTextController(leftSymbol: 'R\$ ');
  bool _checkConfiguration() => true;
  num daysLeft = 31;
  int currentDay = 1;
  SharedPreferences? prefs;
  String lastUpdated = "";
  DateTime fakeDate = DateTime.now();
  var nomeComprinhaTextEditingController = TextEditingController();
  int fakeDateOffset = 0;

  @override
  void initState() {
    super.initState();
    if (_checkConfiguration()) {
      () async {
        DateTime now = DateTime.now();
        daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        var pref = await SharedPreferences.getInstance();
        prefs = pref;
        setState(() {
          _budget = pref.getDouble('budget') ?? defaultBudget;
          double? av = pref.getDouble('available');
          moneyLeft = pref.getDouble('moneyLeft') ?? defaultBudget;
          lastUpdated = pref.getString('lastUpdated') ?? "";
          currentDay = DateTime.now().day;
          final String musicsString = pref.getString('comprinhas') ?? "";
          if (musicsString.isNotEmpty) {
            comprinhas = Comprinha.decode(musicsString);
          }
          controller.text = _budget.toStringAsFixed(2);
          if (av == null) {
            calculateAvailableMoneyFromZero();
            lastUpdated =
                DateTime.now().toString().substring(0, "2022-00-00".length);
          } else {
            available = av;
            var today = DateTime.now();
            DateTime dateLastUpdated = DateTime.parse(lastUpdated);
            var monthsPassed = today.month - dateLastUpdated.month;
            if (monthsPassed < 0) {
              monthsPassed = 12 + now.month - dateLastUpdated.month;
            }
            if (monthsPassed > 0) {
              moneyLeft += _budget * monthsPassed;
              pref.setDouble('moneyLeft', moneyLeft);
            }

            var daysPassedSinceLastUpdate = daysBetween(dateLastUpdated, now);

            if (daysPassedSinceLastUpdate > 0) {
              var amountToAdd =
                  (_budget / daysInMonth) * daysPassedSinceLastUpdate;
              available += amountToAdd;

              pref.setDouble('available', available);
              lastUpdated =
                  DateTime.now().toString().substring(0, "2022-00-00".length);
              pref.setString('lastUpdated', lastUpdated);
            }
          }
        });
      }();
    }
  }

  void advanceDay() {
    setState(() {
      fakeDate = fakeDate.add(const Duration(days: 1));
      available += _budget / daysInMonth;
      fakeDateOffset++;
    });
  }

  void goBackOneDay() {
    setState(() {
      fakeDate = fakeDate.subtract(const Duration(days: 1));
      available -= _budget / daysInMonth;
      fakeDateOffset--;
    });
  }

  void calculateAvailableMoney() {
    setState(() {
      daysLeft = 30 - currentDay + 1;
      //var amountToAddToday = ((_budget - available) / daysLeft);
      var amountToAddToday = _budget / daysInMonth;

      available += amountToAddToday;
    });
  }

  void calculateAvailableMoneyFromZero() {
    setState(() {
      available = (_budget / daysInMonth) * currentDay;
      prefs?.setDouble('available', available);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
        drawer: NavigationDrawerWidget(themeNotifier),
        appBar: AppBar(
          title: Text(widget.title ?? ""),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          'Budget restante:',
                        ),
                      ),
                      Text(
                        'R\$ ' '${moneyLeft.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      /*SizedBox(
                      width: 100.0,
                      child: 
                      TextField(
                        controller: controller,
                        onChanged: (text) {
                          setState(() {
                            _budget = controller.numberValue;
                            prefs?.setDouble('budget', _budget);
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),*/
                      // ElevatedButton(
                      //   onPressed: () => calculateAvailableMoneyFromZero(),
                      //   child: const Text(
                      //     "Resetar",
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const Divider(),
                Container(
                  margin: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        fakeDateOffset != 0
                            ? 'Você poderá gastar:'
                            : 'Você pode gastar:',
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'R\$ ' '${available.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: available >= 0
                                    ? (fakeDateOffset != 0
                                        ? Colors.grey
                                        : Colors.green)
                                    : Colors.red,
                                fontSize: 30),
                          ),
                          const SizedBox(width: 3),
                          const Text("/dia"),
                        ],
                      ),
                    ],
                  ),
                ),
                // const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () => goBackOneDay(),
                        child: const Text(
                          "-",
                        )),
                    Text(formatDate2(fakeDate)),
                    ElevatedButton(
                      onPressed: () => advanceDay(),
                      child: const Text(
                        "+",
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        controller: nomeComprinhaTextEditingController,
                        onChanged: (text) {
                          novaComprinha.nome = text;
                        },
                        decoration: const InputDecoration(
                          helperText: "Minha comprinha",
                        ),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Flexible(
                      child: SizedBox(
                        width: 80,
                        child: TextField(
                          controller: novaComprinhaController,
                          onChanged: (value) {
                            novaComprinha.valor =
                                novaComprinhaController.numberValue;
                          },
                          decoration:
                              const InputDecoration(helperText: "Valor"),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          available =
                              prefs?.getDouble('available') ?? available;
                          fakeDate = DateTime.now();
                          fakeDateOffset = 0;
                          comprinhas.add(Comprinha(formatDate(DateTime.now()),
                              novaComprinha.nome, novaComprinha.valor));
                          available -= novaComprinha.valor;
                          moneyLeft -= novaComprinha.valor;
                          prefs?.setDouble('available', available);
                          prefs?.setDouble('moneyLeft', moneyLeft);
                          final String encodedData =
                              Comprinha.encode(comprinhas);
                          prefs?.setString('comprinhas', encodedData);
                          novaComprinhaController =
                              MoneyMaskedTextController(leftSymbol: 'R\$ ');
                          nomeComprinhaTextEditingController.clear();
                          novaComprinha = Comprinha("", "", 0.0);
                        });
                      },
                      child: const Text('+'),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: comprinhas.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(comprinhas[index].date),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 170,
                          child: Text(
                            comprinhas[index].nome,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('R\$ '
                            '${comprinhas[index].valor.toStringAsFixed(2)}'),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              available =
                                  prefs?.getDouble('available') ?? available;
                              fakeDate = DateTime.now();
                              available += comprinhas[index].valor;
                              moneyLeft += comprinhas[index].valor;
                              comprinhas.removeAt(index);
                              final String encodedData =
                                  Comprinha.encode(comprinhas);
                              prefs?.setDouble('available', available);
                              prefs?.setDouble('moneyLeft', moneyLeft);
                              prefs?.setString('comprinhas', encodedData);
                              fakeDateOffset = 0;
                            });
                          },
                          child: const Text('-'),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Text(
                  "Desenvolvido por Gabriel S.A.",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      );
    });
  }
}
