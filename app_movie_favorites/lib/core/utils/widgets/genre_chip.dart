import 'package:flutter/material.dart';

class GenreChip extends StatelessWidget {
  final String genreName;
  
  const GenreChip({super.key, required this.genreName});
  
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        genreName,
        style: TextStyle(fontSize: 12),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
