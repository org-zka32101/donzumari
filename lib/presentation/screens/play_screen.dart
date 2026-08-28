import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../game/donzumari_game.dart';

class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  late DonzumariGame _gameInstance;
  late GameWidget _gameWidget;
  double _currentHeight = 0;

  @override
  void initState() {
    super.initState();
    _gameInstance = DonzumariGame();
    _gameWidget = GameWidget(game: _gameInstance);
  }

  @override
  void dispose() {
    _gameInstance.removeFromParent();
    super.dispose();
  }

  void _handlePlaceParcel() {
    if (!_gameInstance.isGameActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ゲームが終了しています')),
      );
      return;
    }

    // Add a simple parcel at the center
    _gameInstance.addParcel(
      Vector2(_gameInstance.doorwayX.toDouble(), 50),
      const Vector2(20, 20),
      0,
    );

    setState(() {
      _currentHeight = _gameInstance.getTowerHeight();
    });

    if (_gameInstance.hasCollapsed) {
      _showCollapseDialog();
    }
  }

  void _showCollapseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('崩落！'),
        content: Text('高さ: ${_currentHeight.toStringAsFixed(1)} cm'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleRetry();
            },
            child: const Text('もう一度'),
          ),
        ],
      ),
    );
  }

  void _handleRetry() {
    setState(() {
      _gameInstance.reset();
      _currentHeight = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('積む'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Game area
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _gameWidget,
            ),
          ),
          // Controls and info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '高さ: ${_currentHeight.toStringAsFixed(1)} cm',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  '積み重ねた荷物: ${_gameInstance.stackedParcels.length}個',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _gameInstance.isGameActive ? _handlePlaceParcel : null,
                  icon: const Icon(Icons.add),
                  label: const Text('荷物を配置'),
                ),
                const SizedBox(height: 8),
                if (_gameInstance.hasCollapsed)
                  ElevatedButton(
                    onPressed: _handleRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('もう一度'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
