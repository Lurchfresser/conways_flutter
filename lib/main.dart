import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Conways Flutter',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Column(
          children: [
            const Expanded(
              child: GameGrid(),
            ),
            SafeArea(
                child: NavigationBar(destinations: [
              IconButton(
                  onPressed: () {
                    appState.calCulateNextGeneration();
                  },
                  icon: Icon(Icons.play_arrow)),
              Placeholder(),
            ])),
          ],
        ),
      );
    });
  }
}

class GameGrid extends StatelessWidget {
  const GameGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var list = appState.cells;
    int rowlength = list.first.length;

    return GridView.builder(
      itemCount: 2500,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: list.first.length,
          ),
          itemBuilder: (context, index){
            int row = (index / rowlength).floor() * rowlength;
            print(row);
            return Cell(row,index %rowlength);
          },
    );
  }
}

class Cell extends StatelessWidget {
  int row;
  int column;

  Cell(this.row, this.column, {super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var color = appState.cells[row][column] ? Colors.black : Colors.white;

    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent), color: color),
      ),
      onTap: () => {appState.toggleCellState(row, column)},
    );
  }
}

class MyAppState extends ChangeNotifier {
  int columns = 50;
  int rows = 50;
  var cells = List.generate(
      50, (index) => List.filled(50, false, growable: false),
      growable: false);

  toggleCellState(row, column) {
    cells[row][column] = !cells[row][column];
    notifyListeners();
  }

  calCulateNextGeneration() {
    List<List<bool>> list = List.generate(
        rows, (index) => List.filled(columns, false, growable: false),
        growable: false);
    List<List<int>> numberOfNeighbours = List.generate(
        rows, (index) => List.filled(columns, 0, growable: false),
        growable: false);

    for (var i = 0; i < cells.length; i++) {
      for (var j = 0; j < cells[i].length; j++) {
        if(cells[i][j]){
        for (var i2 = i-1; i2 <= i+1; i2++) {
          for (var j2 = j-1; j2 <= j+1; j2++) {
            if(i2 >= 0 && j2 >= 0 && i2 < cells.length && j2 < cells[i].length && !(i2 == i && j2 == j)){
              numberOfNeighbours[i2][j2]++;
            }
          }
        }
      }
      }

    }
    
    for (var i = 0; i < cells.length; i++) {
      for (var j = 0; j < cells[i].length; j++) {
        if (!cells[i][j]){
          cells[i][j] = numberOfNeighbours[i][j] == 3;
        }
        else{
          cells[i][j] = (numberOfNeighbours[i][j] == 3 || numberOfNeighbours[i][j] == 2);
        }
      }
    }
    notifyListeners();
  }
}
