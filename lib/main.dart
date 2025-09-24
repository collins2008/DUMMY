import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:home_widget/home_widget.dart';

// ----------------- DATA MODELS -----------------
class Habit {
  String name;
  int streak;
  bool doneToday;

  Habit({required this.name, this.streak = 0, this.doneToday = false});

  void toggleToday() {
    doneToday = !doneToday;
    if (doneToday) {
      streak++;
    } else {
      streak = streak > 0 ? streak - 1 : 0;
    }
  }
}

class HabitGarden {
  List<Habit> habits = [];

  void addHabit(String name) {
    habits.add(Habit(name: name));
  }
}

// ----------------- MAIN APP -----------------
void main() {
  runApp(const HabitGardenApp());
}

class HabitGardenApp extends StatelessWidget {
  const HabitGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Garden',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HabitGardenScreen(),
      routes: {
        '/widgetInfo': (context) => const WidgetInfoScreen(),
      },
    );
  }
}

// ----------------- HOME SCREEN -----------------
class HabitGardenScreen extends StatefulWidget {
  @override
  State<HabitGardenScreen> createState() => _HabitGardenScreenState();
}

class _HabitGardenScreenState extends State<HabitGardenScreen> {
  final HabitGarden garden = HabitGarden();
  final TextEditingController controller = TextEditingController();

  void _addHabit() {
    if (controller.text.isNotEmpty) {
      setState(() {
        garden.addHabit(controller.text);
      });
      controller.clear();
    }
  }

  void _toggleHabit(Habit habit) {
    setState(() {
      habit.toggleToday();
      updateHomeWidget(habit);
    });
  }

  void updateHomeWidget(Habit h) {
    HomeWidget.saveWidgetData<String>('habit_name', h.name);
    HomeWidget.saveWidgetData<int>('habit_streak', h.streak);
    HomeWidget.updateWidget(
      name: 'HabitWidgetProvider',
      iOSName: 'HabitWidget',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Garden'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/widgetInfo');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a new habit',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addHabit,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: garden.habits.length,
              itemBuilder: (context, index) {
                final habit = garden.habits[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: Lottie.asset(
                      'assets/lottie/plant.json',
                      width: 50,
                      height: 50,
                      repeat: true,
                    ),
                    title: Text(habit.name),
                    subtitle: Text('${habit.streak} day streak'),
                    trailing: IconButton(
                      icon: Icon(
                        habit.doneToday
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: habit.doneToday ? Colors.green : Colors.grey,
                      ),
                      onPressed: () => _toggleHabit(habit),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- WIDGET INFO SCREEN -----------------
class WidgetInfoScreen extends StatelessWidget {
  const WidgetInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Widget Info")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text(
              "To enable a homescreen widget, "
              "go to your home screen, long-press, and add it from widgets.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
