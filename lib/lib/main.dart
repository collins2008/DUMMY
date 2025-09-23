// HabitTracker - Flutter MVP UI
// Single-file Flutter app (lib/main.dart)
// ---------------------------------------------------------
// What this file contains:
// - Onboarding screen
// - Home dashboard with habit cards
// - Add Habit screen (form + streak-style selector)
// - Habit detail screen (calendar-like view + stats)
// - Simple in-memory store (singleton) for habits
// - Basic animations (animated icon placeholders, confetti stub)
//
// Notes & next steps:
// 1) This is UI-first and uses an in-memory store. To persist locally add Hive/SharedPreferences/SQLite.
// 2) Animations: Lottie is referenced in the UI (placeholders). Add Lottie JSON files under assets and include in pubspec.
// 3) Android homescreen widget is not included here (requires platform-specific AppWidget). I left comments where to integrate.
// 4) To run: create a Flutter project and replace lib/main.dart with this file. Add dependency `lottie: ^2.2.0` to pubspec.
// ---------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

void main() {
  runApp(HabitApp());
}

// ---------------------------- Models ----------------------------
class Habit {
  final String id;
  String name;
  String style; // e.g. 'fire', 'plant', 'book', 'gem', 'moon'
  int streak;
  bool autoTick;
  DateTime startDate;
  List<DateTime> misses; // days user unticked/missed

  Habit({
    required this.id,
    required this.name,
    required this.style,
    this.streak = 0,
    this.autoTick = true,
    DateTime? startDate,
    List<DateTime>? misses,
  })  : this.startDate = startDate ?? DateTime.now(),
        this.misses = misses ?? [];
}

// Simple singleton in-memory store. Replace with persistent store later.
class HabitStore extends ChangeNotifier {
  static final HabitStore _instance = HabitStore._internal();
  factory HabitStore() => _instance;
  HabitStore._internal();

  final List<Habit> _habits = [];
  List<Habit> get habits => List.unmodifiable(_habits);

  void addHabit(Habit h) {
    _habits.add(h);
    notifyListeners();
  }

  void updateHabit(Habit h) {
    final i = _habits.indexWhere((e) => e.id == h.id);
    if (i != -1) {
      _habits[i] = h;
      notifyListeners();
    }
  }

  void toggleToday(Habit h) {
    // If user unticks today (remove auto tick) -> add to misses
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    if (h.misses.any((d) => isSameDay(d, day))) {
      h.misses.removeWhere((d) => isSameDay(d, day));
    } else {
      h.misses.add(day);
    }
    // Recalculate streak simply: if last day missed -> reset to 0 else increment
    h.streak = calculateStreak(h);
    notifyListeners();
  }

  int calculateStreak(Habit h) {
    // naive: count days from today backwards until a miss is found
    int count = 0;
    DateTime day = DateTime.now();
    day = DateTime(day.year, day.month, day.day);
    while (true) {
      if (h.misses.any((d) => isSameDay(d, day))) break;
      // stop if before startDate
      if (day.isBefore(DateTime(h.startDate.year, h.startDate.month, h.startDate.day))) break;
      count++;
      day = day.subtract(Duration(days: 1));
      // safety
      if (count > 10000) break;
    }
    return count;
  }

  void seedSample() {
    if (_habits.isNotEmpty) return;
    addHabit(Habit(id: 'h1', name: 'Workout', style: 'fire', streak: 12));
    addHabit(Habit(id: 'h2', name: 'Read 30 mins', style: 'book', streak: 7));
    addHabit(Habit(id: 'h3', name: 'Meditate', style: 'moon', streak: 21));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// ---------------------------- App ----------------------------
class HabitApp extends StatefulWidget {
  @override
  _HabitAppState createState() => _HabitAppState();
}

class _HabitAppState extends State<HabitApp> {
  final HabitStore store = HabitStore();
  bool _seenOnboarding = false;

  @override
  void initState() {
    super.initState();
    store.seedSample();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Garden',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: _seenOnboarding ? HomeScreen() : OnboardingScreen(onContinue: () {
        setState(() {
          _seenOnboarding = true;
        });
      }),
    );
  }
}

// ---------------------------- Onboarding ----------------------------
class OnboardingScreen extends StatelessWidget {
  final VoidCallback onContinue;
  OnboardingScreen({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(),
              Center(child: Icon(Icons.local_fire_department, size: 96, color: Colors.deepOrange)),
              SizedBox(height: 24),
              Text('Welcome to Habit Garden', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Habits that grow with you. We auto-tick each day, so you keep your flow — just untick if you miss.', textAlign: TextAlign.center),
              Spacer(),
              ElevatedButton(onPressed: onContinue, child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Get started'))),
              SizedBox(height: 12),
              TextButton(onPressed: onContinue, child: Text('Skip'))
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------- Home Screen ----------------------------
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitStore store = HabitStore();

  @override
  void initState() {
    super.initState();
    store.addListener(_onChange);
  }

  @override
  void dispose() {
    store.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final habits = store.habits;
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Garden'),
        actions: [
          IconButton(onPressed: () {
            // TODO: Open settings
          }, icon: Icon(Icons.settings))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: habits.isEmpty ? _emptyState() : ListView.builder(
          itemCount: habits.length,
          itemBuilder: (context, i) {
            final h = habits[i];
            return HabitCard(habit: h, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: h)));
            }, onToggleToday: () {
              store.toggleToday(h);
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddHabitScreen()));
          if (created == true) setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.park, size: 88, color: Colors.greenAccent),
          SizedBox(height: 12),
          Text('No habits yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Tap + to add your first habit. Each habit can have its own animation style.'),
        ],
      ),
    );
  }
}

// ---------------------------- Habit Card ----------------------------
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onToggleToday;
  HabitCard({required this.habit, required this.onTap, required this.onToggleToday});

  Widget _buildIcon(BuildContext context) {
    // Placeholder: use Lottie when provided
    final map = {
      'fire': 'assets/lottie/fire.json',
      'plant': 'assets/lottie/plant.json',
      'book': 'assets/lottie/book.json',
      'gem': 'assets/lottie/gem.json',
      'moon': 'assets/lottie/moon.json',
    };
    final path = map[habit.style];
    if (path != null) {
      return SizedBox(width: 64, height: 64, child: LottieBuilder.asset(path, repeat: true));
    }
    // fallback
    return CircleAvatar(child: Text(habit.name.substring(0,1).toUpperCase()));
  }

  @override
  Widget build(BuildContext context) {
    final todayDone = !habit.misses.any((d) => HabitStore.isSameDay(d, DateTime.now()));
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              _buildIcon(context),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('${habit.streak} day streak', style: TextStyle(color: Colors.grey[700])),
                    SizedBox(height: 6),
                    LinearProgressIndicator(value: min(habit.streak / 30.0, 1.0)),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Column(
                children: [
                  IconButton(onPressed: onToggleToday, icon: Icon(todayDone ? Icons.check_circle : Icons.radio_button_unchecked, color: todayDone ? Colors.green : Colors.grey)),
                  SizedBox(height: 4),
                  Text('Today')
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------- Add Habit Screen ----------------------------
class AddHabitScreen extends StatefulWidget {
  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _style = 'fire';
  bool _autoTick = true;

  final styles = ['fire', 'plant', 'book', 'gem', 'moon'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Habit name', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              SizedBox(height: 12),
              Text('Choose streak style', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: styles.map((s) => ChoiceChip(
                  label: Text(s),
                  selected: _style == s,
                  onSelected: (_) => setState(() => _style = s),
                )).toList(),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(value: _autoTick, onChanged: (v) => setState(() => _autoTick = v ?? true)),
                  SizedBox(width: 8),
                  Text('Auto-tick daily (default)')
                ],
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final h = Habit(
                        id: UniqueKey().toString(),
                        name: _name,
                        style: _style,
                        streak: 0,
                        autoTick: _autoTick,
                        startDate: DateTime.now(),
                      );
                      HabitStore().addHabit(h);
                      Navigator.pop(context, true);
                    }
                  },
                  child: Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Create Habit')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------- Habit Detail Screen ----------------------------
class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  HabitDetailScreen({required this.habit});

  @override
  _HabitDetailScreenState createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit h;

  @override
  void initState() {
    super.initState();
    h = widget.habit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(h.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 100, height: 100, child: _buildLargeIcon()),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('${h.streak} day streak', style: TextStyle(color: Colors.grey[700])),
                    SizedBox(height: 12),
                    ElevatedButton(onPressed: () {
                      HabitStore().toggleToday(h);
                      setState(() {});
                    }, child: Text('Toggle Today'))
                  ],
                )
              ],
            ),
            SizedBox(height: 20),
            Text('Last 14 days', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildMiniCalendar(),
            SizedBox(height: 16),
            Text('Stats', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                _statTile('Best', '${max(h.streak, 0)}d'),
                _statTile('Started', '${h.startDate.year}-${h.startDate.month}-${h.startDate.day}'),
                _statTile('Auto-tick', h.autoTick ? 'On' : 'Off'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _statTile(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeIcon() {
    final map = {
      'fire': 'assets/lottie/fire.json',
      'plant': 'assets/lottie/plant.json',
      'book': 'assets/lottie/book.json',
      'gem': 'assets/lottie/gem.json',
      'moon': 'assets/lottie/moon.json',
    };
    final path = map[h.style];
    if (path != null) return LottieBuilder.asset(path);
    return CircleAvatar(radius: 40, child: Text(h.name.substring(0,1).toUpperCase()));
  }

  Widget _buildMiniCalendar() {
    final days = List<DateTime>.generate(14, (i) => DateTime.now().subtract(Duration(days: 13 - i)));
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, i) {
          final d = days[i];
          final missed = h.misses.any((m) => HabitStore.isSameDay(m, d));
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: missed ? Colors.red[200] : Colors.green[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('${d.day}')),
                ),
                SizedBox(height: 6),
                Text(_shortWeekday(d.weekday), style: TextStyle(fontSize: 12))
              ],
            ),
          );
        },
      ),
    );
  }

  String _shortWeekday(int w) {
    const map = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return map[(w - 1) % 7];
  }
}

// ---------------------------------------------------------
// PUBSPEC SNIPPET (Add to your pubspec.yaml):
//
// dependencies:
//   flutter:
//     sdk: flutter
//   lottie: ^2.2.0
//
// assets:
//   - assets/lottie/fire.json
//   - assets/lottie/plant.json
//   - assets/lottie/book.json
//   - assets/lottie/gem.json
//   - assets/lottie/moon.json
//
// ---------------------------------------------------------
// Android widget note:
// To create a homescreen widget on Android (Samsung), you'll need to implement an AppWidgetProvider in native Android (Kotlin/Java) and use MethodChannel or BackgroundService to fetch data from the Flutter app's local storage. For Flutter-based approaches consider `glance` for Jetpack Glance or the community `home_widget` plugin. Widget animations should be lightweight — consider showing static SVGs/gifs instead of full Lottie in the widget.
//
// ---------------------------------------------------------
// End of file
