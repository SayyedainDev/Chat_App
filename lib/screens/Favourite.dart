import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoritesModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider Favorites Demo',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(),
    );
  }
}

class FavoritesModel extends ChangeNotifier {
  final List<String> _favorites = [];

  List<String> get items => _favorites;

  void toggleFavorite(String item) {
    if (_favorites.contains(item)) {
      _favorites.remove(item);
    } else {
      _favorites.add(item);
    }
    notifyListeners();
  }

  bool isFavorite(String item) => _favorites.contains(item);

  void clear() {
    _favorites.clear();
    notifyListeners();
  }
}

class HomeScreen extends StatelessWidget {
  final List<String> items = ['Apple', 'Banana', 'Orange', 'Grapes', 'Mango'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Consumer<FavoritesModel>(
            builder: (context, favorites, child) {
              final isFav = favorites.isFavorite(item);
              return ListTile(
                title: Text(item),
                trailing: IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null,
                  ),
                  onPressed: () {
                    favorites.toggleFavorite(item);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Provider.of<FavoritesModel>(context, listen: false).clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Favorites cleared')),
              );
            },
          )
        ],
      ),
      body: Consumer<FavoritesModel>(
        builder: (context, favorites, child) {
          if (favorites.items.isEmpty) {
            return Center(child: Text('No favorites yet'));
          }
          return ListView(
            children: favorites.items
                .map((item) => ListTile(title: Text(item)))
                .toList(),
          );
        },
      ),
    );
  }
}
