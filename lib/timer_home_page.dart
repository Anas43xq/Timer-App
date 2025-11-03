import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'widgets/time_dropdown.dart';
import 'widgets/settings_dialog.dart';

class TimerHomePage extends StatefulWidget {
  const TimerHomePage({super.key});

  @override
  State<TimerHomePage> createState() => _TimerHomePageState();
}

class _TimerHomePageState extends State<TimerHomePage> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  int _currSec = 0;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _isCountUp = true;

  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  ThemeMode _themeMode = ThemeMode.dark;
  double _fontSize = 48.0;

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _increaseFontSize() {
    setState(() {
      if (_fontSize < 80) _fontSize += 4;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > 20) _fontSize -= 4;
    });
  }

  void _playSound() async {
    try {
      await _audioPlayer.play(AssetSource('CompleteTime.mp3'));
    } catch (e) {
      showSnackBarMessage("hi");
    }
  }

  void _startTimer() {
    if (!_isPaused && _hours == 0 && _minutes == 0 && _seconds == 0) {
      showSnackBarMessage('Please set a timer greater than 0');
      return;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;

      if (_currSec == 0 && !_isCountUp) {
        _currSec = _hours * 3600 + _minutes * 60 + _seconds;
      }
    });

    _timer ??= Timer.periodic(const Duration(seconds: 1), (t) => onTimeChange());
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void handleCountUp() {
    _currSec++;
    int targetSeconds = _hours * 3600 + _minutes * 60 + _seconds;
    if (_currSec >= targetSeconds) {
      _stopTimer();
      _playSound();
      showSnackBarMessage('Timer Complete!');
    }
  }

  void handleCountDown() {
    _currSec--;
    if (_currSec <= 0) {
      _currSec = 0;
      _stopTimer();
      _playSound();
      showSnackBarMessage('Countdown Complete!');
    }
  }

  void onTimeChange() {
    if (_isPaused) return;

    setState(() {
      if (_isCountUp) {
        handleCountUp();
      } else {
        handleCountDown();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _currSec = 0;
    });
  }

  String _formatTime(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;

    return '${h.toString().padLeft(2, '0')} : ${m.toString().padLeft(2, '0')} : ${s.toString().padLeft(2, '0')}';
  }

  Widget buildSetting() {
    return SettingsDialog(
      isDarkMode: _themeMode == ThemeMode.dark,
      fontSize: _fontSize,
      onToggleTheme: _toggleTheme,
      onIncreaseFontSize: _increaseFontSize,
      onDecreaseFontSize: _decreaseFontSize,
    );
  }

  void _showSettings() {
    showDialog(context: context, builder: (context) => buildSetting());
  }

  void showSnackBarMessage(String message) {
    final isDark = _themeMode == ThemeMode.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDark
            ? const Color.fromARGB(255, 30, 30, 30)
            : Colors.grey[300],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _themeMode == ThemeMode.dark
          ? ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      )
          : ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('⏱️ Timer App'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showSettings,
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimerTypeSelector(),
            const SizedBox(height: 40),
            _buildTimeDisplay(),
            const SizedBox(height: 40),
            if (!_isRunning && !_isPaused) _buildTimeInput(),
            const SizedBox(height: 40),
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerTypeSelector() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: true, label: Text('Count Up'), icon: Icon(Icons.arrow_upward)),
        ButtonSegment(value: false, label: Text('Countdown'), icon: Icon(Icons.arrow_downward)),
      ],
      selected: {_isCountUp},
      onSelectionChanged: _isRunning || _isPaused
          ? null
          : (Set<bool> newSelection) {
        setState(() {
          _isCountUp = newSelection.first;
          _currSec = 0;
        });
      },
    );
  }

  Widget _buildTimeDisplay() {
    return Text(
      _formatTime(_currSec),
      style: TextStyle(
        fontSize: _fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildTimeInput() {
    return Column(
      children: [
        const Text(
          'Set Target Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TimeDropdown(
              label: 'Hours',
              value: _hours,
              max: 23,
              onChanged: (value) => setState(() => _hours = value),
            ),
            const SizedBox(width: 8),
            const Text(':', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            TimeDropdown(
              label: 'Minutes',
              value: _minutes,
              max: 59,
              onChanged: (value) => setState(() => _minutes = value),
            ),
            const SizedBox(width: 8),
            const Text(':', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            TimeDropdown(
              label: 'Seconds',
              value: _seconds,
              max: 59,
              onChanged: (value) => setState(() => _seconds = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    Icon buttonIcon;
    String buttonLabel;

    if (!_isRunning) {
      buttonIcon = const Icon(Icons.play_arrow);
      buttonLabel = 'Start';
    } else if (!_isPaused) {
      buttonIcon = const Icon(Icons.pause);
      buttonLabel = 'Pause';
    } else {
      buttonIcon = const Icon(Icons.play_arrow);
      buttonLabel = 'Resume';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            if (!_isRunning) {
              _startTimer();
            } else if (!_isPaused) {
              _pauseTimer();
            } else {
              _startTimer();
            }
          },
          icon: buttonIcon,
          label: Text(buttonLabel),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _resetTimer,
          icon: const Icon(Icons.stop),
          label: const Text('Reset'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }
}
