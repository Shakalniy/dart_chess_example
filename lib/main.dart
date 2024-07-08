import 'package:flutter/material.dart';
import 'package:dartchess/dartchess.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  List<String> moves = [];
  final setup = Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
  var pos;
  TextEditingController controller = TextEditingController();
  String whoMove = 'First player move';
  bool isFirst = true;

  void sendMove() {
    String strMove = controller.text.trim().isEmpty ? "aa" : controller.text.trim();
    Move? move = Move.fromUci(strMove);
    if (move == null) {
      showAlert("Вы ввели ход некорректно");
    }
    else {
      if (pos.isLegal(move)) {
        update(move);
      }
      else {
        showAlert("Данный ход в текущей позиции невозможен");
      }
    }
  }

  void update(Move move) {
    setState(() {
      moves.add(move.uci);
      pos = pos.play(move);
      isFirst = !isFirst;
      whoMove = isFirst ? 'First player move' : 'Second player move';
    });
    controller.clear();
    String message = "";

    if (pos.isCheck){
      message += "На доске шах. ";
    }
    if (pos.isCheckmate) {
      message += "На доске мат. ";
    }
    if (pos.isStalemate) {
      message += "На доске пат. ";
    }
    if (pos.isGameOver) {
      message += "Игра окончена. ";
    }
    if (pos.isInsufficientMaterial) {
      message += "У обеих сторон нет выигрышного материала. ";
    }
    if (message.isEmpty) {
      message = "Ничего не произойти. ";
    }
    showAlert(message);
  }

  void deleteAll() {
    setState(() {
      moves = [];
      isFirst = true;
      whoMove = 'First player move';
      pos = pos = Chess.fromSetup(setup);
    });
    controller.clear();
  }

  void showAlert(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "RobotoSlab",
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    setState(() {
      pos = Chess.fromSetup(setup);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50,),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "$whoMove (e2e4) - Uci notation"
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              "${pos.fen} - FEN notation",
              style: const TextStyle(
                fontSize: 18
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: <Widget>[
                  for (var move in moves)
                    Text(move)
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const  EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: deleteAll,
              child: const Icon(Icons.delete),
            ),
            FloatingActionButton(
              onPressed: sendMove,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
